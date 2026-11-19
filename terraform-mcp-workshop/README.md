# Terraform MCP + Claude Code: a local infrastructure workshop

Prepared for Saravanan Gnanaguru and HUG Accra • 19 November 2026

Session slides: [docs/session-slides.md](docs/session-slides.md). Diagram notes (manual vs AI-driven IaC, MCP architecture, deployment options): [docs/session-intro.md](docs/session-intro.md).

## Outcome and scope

Use Claude Code and Terraform MCP to understand provider documentation, author infrastructure, validate it and review a real Terraform plan. Optionally create a local web container, verify it, change a port and clean up.

No AWS account, AWS credentials, HCP Terraform account or cloud provisioning is needed. Claude Code does require your own supported login/billing access. Internet is required for initial installations, image/provider downloads, registry lookups and the AI service. This is not an offline AI lab.

Allow 45–60 minutes after prerequisites are installed. Commands target macOS with a local Docker Desktop engine; Linux users can follow the lab after installing Docker Engine, Terraform and Claude Code. Windows users should use WSL2 with Docker Desktop WSL integration, keeping all commands and files inside WSL. Do not mix PowerShell paths with these shell commands.

The included application is deliberately a **static Meeting Session Pulse landing page**, not the full polling product. This keeps infrastructure reproducible. The final section explains infrastructure for an agentic application; that extension is not implemented here.

Validation status: documentation checked against official sources; JSON and package contents checked during preparation. Terraform, Docker and Claude Code are not installed in the authoring environment, so this kit has NOT been end-to-end executed. Complete the rehearsal checklist before distributing it as tested.

## Why the workshop is shaped this way

Every step below ends with a **Why we do this** note. The overall logic is a safe, verifiable loop for AI-assisted infrastructure work:

1. **Ground the AI in real documentation** (steps 3–4), so it writes provider syntax from the registry instead of from memory.
2. **Generate or review code** (step 5), then **check it mechanically** with `fmt` and `validate` (step 6).
3. **Preview before changing anything** with a plan (step 7), because a plan is the point where a human catches a wrong assumption cheaply.
4. **Only then change real (local) resources**, one deliberate step at a time (steps 8–10), and clean up afterwards.

Each stage produces evidence that the next stage depends on. Skipping one means trusting the AI's word for it.

## 1. Install prerequisites

**Why we do this:** Four tools each play a distinct role. Terraform is the engine that turns `.tf` files into resources. Claude Code is the AI agent that reads, writes and runs things on your behalf. Docker Desktop provides the local engine where the resources actually live, which is why no cloud account is needed. The verification commands prove each tool works *before* the session, so a later failure points at your configuration rather than at a missing install. Checking that Docker reports a working **server** (not just a client) matters because the Docker CLI installs without the engine running, and the Terraform provider needs the engine.

On macOS, with Homebrew already installed:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install --cask claude-code
```

Install Docker Desktop for your Mac architecture from https://docs.docker.com/desktop/setup/install/mac-install/ and start it. Existing installations do not need reinstalling. Follow the vendor's applicable licensing terms.

Verify in Terminal:

```bash
terraform version
claude --version
docker version
docker info
docker context show
```

Expected: Terraform and Claude versions print, and Docker reports BOTH a client and a working server. If the server fails, open Docker Desktop and wait for its engine to start.

## 2. Open the lab directory and select a local Docker endpoint

**Why we do this:** Two safety properties depend on this step. First, running everything from the project root means Claude Code picks up `CLAUDE.md` (the lab's safety rules) and the project-scoped MCP configuration, and `-chdir=infra` keeps Terraform working in the right folder. Second, the Docker CLI and the Terraform Docker provider can resolve *different* endpoints, for example the CLI pointing at a remote or SSH host while the provider uses the local socket. Inspecting the context and exporting `DOCKER_HOST` makes both use the same **local** engine, so Terraform can never create containers on a machine you did not intend. Launching Claude from this terminal means its commands inherit that setting.

Extract this ZIP, open Terminal and change into its `terraform-mcp-workshop` directory. Example if extracted into Downloads:

```bash
cd ~/Downloads/terraform-mcp-workshop
pwd
ls
```

You should see README.md, CLAUDE.md, infra/ and site/. All commands below run from this project root and use Terraform's `-chdir=infra` option.

The Docker CLI context and Terraform provider can otherwise point to different sockets. Inspect your context first:

```bash
docker context inspect --format '{{.Endpoints.docker.Host}}'
```

It must be your LOCAL Unix socket, for example `unix:///Users/you/.docker/run/docker.sock` or `unix:///var/run/docker.sock`. If it is an SSH/TCP/remote endpoint, stop and select a local context with `docker context ls` and `docker context use YOUR_LOCAL_CONTEXT`.

For a local Unix socket, run:

```bash
export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
docker info
```

Keep this terminal open and launch Claude from it so its terminal commands inherit the endpoint. Do not copy the Mac socket path into attendee files.

## 3. Register Terraform MCP in Claude Code

**Why we do this:** An AI model's memory of Terraform provider arguments can be outdated or wrong, especially for third-party providers and specific versions. The Terraform MCP server gives Claude tools to look up current provider documentation from the public registry. Specific choices:

- **Docker container, pinned tag (`1.4.1`):** the server runs the same way on every laptop, and a pinned tag stops a surprise upgrade changing tool behaviour mid-workshop.
- **`stdio` transport:** Claude Code launches and talks to the container directly, so no network port is opened for MCP.
- **`--toolsets=registry`:** exposes only read-only public documentation lookups. No Terraform token or HCP account is needed, and the server cannot touch your infrastructure.
- **No Docker socket mounted into the MCP container:** the socket gives root-equivalent control of the host, and a documentation lookup tool has no need for it.
- **`--scope project`:** the configuration is saved in `.mcp.json` inside this folder, so it travels with the lab and does not alter your other projects.
- **Approving prompts, no permission bypass:** the approval prompts are the human checkpoint that the rest of the lab relies on.

We use HashiCorp's self-hosted MCP container and only public registry tools. No Terraform token is needed. MCP's container does NOT need the Docker socket mounted inside it.

```bash
docker pull hashicorp/terraform-mcp-server:1.4.1
claude mcp add --transport stdio --scope project terraform -- docker run -i --rm hashicorp/terraform-mcp-server:1.4.1 stdio --toolsets=registry
claude mcp list
claude
```

The image tag above is the version in the checked repository examples, not a claim that it is the newest release. Keep the successful rehearsal version for the event.

Approve the project and project-scoped MCP configuration when prompted. Inside Claude Code, enter:

```text
/mcp
```

Expected: the `terraform` server connects and registry tools are available. Leave normal permission prompts enabled; do not use permission-bypass options.

If a server named terraform already exists, inspect it with `claude mcp get terraform`. Do not overwrite unrelated user configuration. Use a different project server name if needed and adjust prompts accordingly.

## 4. Prove an actual MCP lookup

**Why we do this:** A connected server is not the same as a server that was used. Models can produce a confident, plausible answer from memory without calling any tool. This step forces a lookup and requires Claude to name the tools it called and the identifiers returned, which gives you evidence you can inspect. The prompt asks about the exact resources and arguments the lab depends on (`image_id`, `ports.ip`, `networks_advanced`, read-only mounts), so the documentation is retrieved *before* any code is written. It also says "do not edit files or run Terraform yet" to keep research separate from action. The failure advice exists so a browser fallback is never presented as an MCP success.

Paste this into Claude Code:

```text
Read CLAUDE.md. Discover the connected Terraform MCP tools. Use the public
registry tools to find the kreuzwerker/docker provider documentation for
version 4.6.0 and its docker_image, docker_network and docker_container
resources. Verify image_id, ports.ip, networks_advanced and read-only host
volume mounts. Show which tools you actually called and the documentation
identifiers or URLs returned. If version-specific retrieval is unavailable,
say so. Do not edit files or run Terraform yet.
```

Look for real tool calls in the conversation. An answer from model memory does not prove MCP was used. If third-party provider retrieval fails, record that limitation, verify MCP with a public AWS provider documentation query, and consult the Docker provider's official registry pages separately. Do not describe a browser fallback as an MCP success.

## 5. Review or generate the infrastructure

**Why we do this:** This is where the retrieved documentation is turned into code. The lab offers two routes because they teach different things:

- **Review route (reliable first rehearsal):** a known-good `infra/main.tf` already exists. Asking Claude to explain every resource, and to compare it with `CLAUDE.md`, tests whether you and the AI actually understand the code before anything runs. "Make only corrections needed" and "do not apply" limit the AI to the smallest change.
- **Generate route (genuine exercise):** you give requirements and let Claude write the code from MCP documentation. Moving `main.tf` aside first, and telling Claude not to read the reference until it has produced its own version, makes the comparison afterwards a fair test of the documentation-grounded workflow.

Why the starter looks the way it does:

- **Provider pinned to 4.6.0 and Terraform `>= 1.6, < 2.0`:** the code you review matches the documentation Claude looked up, and a future provider release cannot silently change behaviour.
- **Image `nginx:1.28-alpine` with `keep_locally = true`:** a small, fixed web server image, kept in the local cache so cleanup does not force a re-download.
- **Dedicated named network:** the container is isolated from other containers on your machine.
- **Port bound to `127.0.0.1`:** only your own computer can reach the page. Binding to all interfaces would expose a lab container to everyone on the same Wi-Fi.
- **`image = docker_image.web.image_id`:** referencing the image resource creates a dependency, so Terraform pulls the image before creating the container.
- **Read-only bind mount of `site/`:** nginx can serve the page but a compromised or misbehaving container cannot modify your host files. Content changes do not require rebuilding an image.
- **Validated `host_port` variable:** a bad port is rejected at plan time with a clear message, not part-way through creating resources.
- **Never run both implementations as `.tf` files:** Terraform loads every `.tf` file in the folder, so two copies would declare duplicate resources. The `.reference` extension is ignored by Terraform.

The included `infra/main.tf` is a fallback/reference implementation. It declares an nginx image, an isolated named network, and a container exposing port 8080 only on localhost. The site directory is mounted read-only. The provider is pinned to 4.6.0; init will generate the provider checksum lock file.

For a reliable first rehearsal, use this prompt:

```text
Using the Terraform documentation you retrieved, review infra/main.tf.
Explain every resource, dependencies, local Docker endpoint, bind mount,
provider pin and localhost port binding. Compare the implementation with
CLAUDE.md. Make only corrections needed for valid provider syntax. Do not
apply. Keep this a static web infrastructure foundation, not a full app.
```

For a genuine generation exercise in a separate copy of this folder, move the supplied file aside before starting:

```bash
mv infra/main.tf infra/main.tf.reference
```

Terraform ignores the .reference file. Then paste:

```text
Generate infra/main.tf from these requirements using Terraform MCP provider
documentation. Do not read main.tf.reference until after generating your
first implementation. Use kreuzwerker/docker version 4.6.0, Terraform >=1.6
and <2.0, nginx:1.28-alpine, image resource with keep_locally=true, network
meeting-pulse-lab and container meeting-pulse-web. Use image_id from the
image resource, attach the network, bind container port 80 to 127.0.0.1 and
a validated numeric host_port variable defaulting to 8080. Mount ../site
read-only at /usr/share/nginx/html using an absolute path derived from
path.module. Output application_url. Use the inherited local DOCKER_HOST.
No cloud backend, provisioners or credentials. Stop after generation.
```

Compare the result with the reference, then continue with whichever implementation you have reviewed. Never run both implementations as .tf files.

## 6. Initialize, format and validate

**Why we do this:** These are the cheapest checks, and none of them creates anything.

- **`init`** downloads the pinned Docker provider and writes `infra/.terraform.lock.hcl`, which records the provider's checksums. Keep that lock file so every laptop installs the identical provider. Do not copy `.terraform/`, because it holds machine-specific downloads.
- **`fmt`** rewrites the files into canonical style, and **`fmt -check`** then confirms nothing is left unformatted, so diffs show real changes rather than whitespace.
- **`validate`** checks syntax, argument names and types against the provider's schema. It catches the typical AI mistake of inventing an argument that does not exist.

Passing validation does **not** prove the plan is correct or that Docker can pull the image. That is what the next step is for. In the agent-equivalent prompt, "smallest correction" and "do not silently change the provider version" stop the AI from "fixing" an error by changing something unrelated, and "report actual results" is there so a failed check is not glossed over.

In another terminal, set the same local DOCKER_HOST from step 2 and enter the project directory. Run:

```bash
terraform -chdir=infra init
terraform -chdir=infra fmt
terraform -chdir=infra validate
terraform -chdir=infra fmt -check
```

Expected: provider installation succeeds and validation reports success. Keep `infra/.terraform.lock.hcl` when sharing the rehearsed project. Do not copy `.terraform/` between laptops. The pinned image tag can still move; record its image digest after rehearsal if you need stricter reproducibility.

Agent equivalent:

```text
Run Terraform init, fmt and validate in infra through your terminal tools.
If a check fails, use provider documentation to diagnose it, make the
smallest correction and rerun the failed check. Report actual results.
Do not apply or silently change the provider version.
```

## 7. Create the real plan: your dry-run stopping point

**Why we do this:** A plan is Terraform's preview. It compares your code with the current state and the real Docker engine, then lists exactly what it would create, change or destroy. This is the moment a human can catch a wrong port, an unexpected replacement or a deletion before it happens, and it is the main review point when an AI wrote the code.

- **`-out=demo.tfplan`** saves the plan so a later `apply` executes exactly what you reviewed, not a fresh calculation that might differ.
- **`show -no-color`** gives a readable version for you, and **`show -json`** gives a structured version that Claude can read reliably.
- **The prompt asks Claude to separate "what the plan verifies" from "what is untested"**, because a plan does not prove the image will pull or the web server will be healthy. That distinction stops overclaiming.
- **Stopping here is intentional.** Code generation, documentation lookup, validation and plan review are all complete without changing a single running resource.

```bash
terraform -chdir=infra plan -out=demo.tfplan
terraform -chdir=infra show -no-color demo.tfplan
terraform -chdir=infra show -json demo.tfplan > infra/plan.json
```

Expected for the untouched starter with fresh state: three managed resource creations (image, network and container). Some image/container values remain known only after apply. Read the actual plan instead of assuming counts.

This is a real Docker-provider plan against your local engine. It does not create the container. It may contact the engine, and init/downloads have already changed local files. It is not an AWS plan. Terraform plan is the preview operation; there is no `terraform dry-run` command.

Paste:

```text
Read infra/plan.json. Explain each proposed resource action, the localhost
exposure and host mount. Identify values known only after apply and any
replacements or deletions. Separate what this plan verifies from runtime
health and image-pull success, which have not been tested. Stop for review.
```

**You can stop here:** the MCP + AI code development + validation + plan objectives are complete. Everything below is optional.

## 8. Optionally provision and check locally

**Why we do this:** Everything so far predicted the result. Applying turns the prediction into a real local container, and the checks confirm it behaves as expected.

- **Apply the saved plan** so what runs is exactly what you reviewed. Because a saved plan skips the yes/no prompt, running the command *is* your approval, so a human, not the agent, should run it.
- **`output -raw application_url`** shows the URL from the Terraform configuration, so you are not guessing the port.
- **`curl` on `/health.json` and `/`** and **`docker ps`** are independent checks that the web server answers and the container is running. They do not rely on Terraform's own report.
- **`plan -detailed-exitcode` afterwards** tests convergence: if the real world matches the code, the exit code is 0. A non-zero result means drift or a configuration that keeps changing, which is a bug worth finding early.

Only after reviewing the saved plan, run:

```bash
terraform -chdir=infra apply demo.tfplan
terraform -chdir=infra output -raw application_url
curl --fail http://127.0.0.1:8080/health.json
curl --fail http://127.0.0.1:8080/
docker ps --filter name=meeting-pulse-web
```

Applying a saved plan does NOT ask for the usual interactive yes/no confirmation: running the command is your approval. Do not let the agent execute it before you approve. If configuration has changed since planning, generate and review a fresh plan first.

Open http://127.0.0.1:8080 in your browser. Expect a Meeting Session Pulse landing page and a JSON health response. This health check verifies web serving only, not a database or an agent.

Recheck convergence:

```bash
terraform -chdir=infra plan -detailed-exitcode
```

Exit codes: 0 = no changes, 2 = changes present, 1 = error. Do not treat 2 as an execution failure. For an unchanged successful deployment, expect 0.

## 9. Demonstrate a controlled infrastructure change

**Why we do this:** Real infrastructure work is mostly changing existing resources, not creating new ones. This step shows the full change loop: edit one input, plan, read the plan, then apply. Using `terraform.tfvars` changes the variable without editing `main.tf`. The plan reveals whether Docker can update the port in place or must **replace** the container, which causes a brief interruption. Asking Claude to explain that, and then checking its answer against the plan, practises not trusting an explanation you have not verified. The nginx content comes from the host folder, so replacing the container does not lose any files. Create a fresh plan after any further edit, because a saved plan is only valid for the state it was made against.

Create persistent configuration for the new port:

```bash
printf 'host_port = 8081
' > infra/terraform.tfvars
terraform -chdir=infra plan -out=change.tfplan
terraform -chdir=infra show -no-color change.tfplan
```

Ask Claude to explain whether the provider proposes replacing the container, which resources are retained, and expected interruption. Inspect the plan before accepting its answer. nginx content comes from the host folder, so a container replacement does not delete those files.

Optionally apply after approval:

```bash
terraform -chdir=infra apply change.tfplan
curl --fail http://127.0.0.1:8081/health.json
```

Use a fresh plan after further edits; do not reuse an old saved plan.

## 10. Clean up only lab resources

**Why we do this:** Cleanup leaves your machine as you found it, and it uses the same plan-then-apply discipline as creation. A destroy plan lists what would be removed, so you can confirm that only `meeting-pulse-web` and `meeting-pulse-lab` are targeted. Terraform only removes what its state knows it created, which is why you must **not delete the state files first**: Terraform would lose track of the resources and leave orphaned containers. Avoid `docker system prune` because it removes *everything* unused on your machine, including images and volumes from unrelated projects. The final `docker ps -a` and `docker network ls` commands independently confirm the removal. Keeping the nginx image cache is deliberate, as it saves a re-download on the next run.

```bash
terraform -chdir=infra plan -destroy -out=cleanup.tfplan
terraform -chdir=infra show -no-color cleanup.tfplan
```

Review that only lab resources are targeted. Then, if approved:

```bash
terraform -chdir=infra apply cleanup.tfplan
docker ps -a --filter name=meeting-pulse-web
docker network ls --filter name=meeting-pulse-lab
```

The web container and lab network should be absent. `keep_locally=true` intentionally retains the nginx image cache. The MCP image and site source files also remain. Never use `docker system prune` as workshop cleanup. Do not delete Terraform state before cleanup.

## 11. Extend the discussion: infrastructure FOR an agentic app

**Why we do this:** The lab used a static page so the infrastructure workflow could be learned without application complexity. This step connects that workflow to the kind of system many attendees will build next. It is an **architecture exercise** on purpose: it practises asking "which requirement does each component serve?" before adding it. The prompt asks for a diagram and backlog only, and tells Claude not to provision anything or claim the agent already works, so design discussion stays separate from implementation. It also reuses the earlier lesson, asking Claude to verify any proposed provider resources with Terraform MCP rather than guessing them.

This is an architecture exercise, not a claim that the static lab contains an AI agent.

Product extension: a Session Planning Agent reads aggregate votes, searches an approved workshop catalogue, checks prerequisites and proposes an agenda for an organiser to review.

| Component | Why add it? | Local illustration |
|---|---|---|
| API | Accept a planning request and expose job status | Python service |
| Agent worker | Execute tool calls and bounded reasoning loops | Separate worker container |
| Model access | Perform inference | External endpoint, or separately provisioned local runtime |
| State | Persist polls, job checkpoints and agendas | Database and named volume |
| Queue | Decouple longer jobs and manage retries | Queue service if workload needs it |
| Tool access | Fetch poll results and approved resources | Narrow application APIs |
| Secrets | Authenticate model/tool requests | Runtime secret injection, not hardcoded Terraform values |
| Observability | Trace model calls, tools, latency and failures | Structured logs and traces |

Do not add all these services just to make a demo look complex. Map each service to a requirement. A GPU is needed only when the selected inference deployment requires one; an app calling a hosted model does not inherently need local GPUs.

Architecture prompt:

```text
Propose how this web infrastructure could support a Session Planning Agent.
The agent reads aggregate poll results, searches an approved catalogue,
checks prerequisites and drafts an agenda for human review. Separate
application code, Terraform-managed infrastructure, runtime secrets and
agent safety controls. Explain which components are required now versus
optional as load grows. Use Terraform MCP to verify provider resources for
any proposed infrastructure. Produce a diagram and implementation backlog
only. Do not provision or claim the extension is already working.
```

Make clear that Terraform MCP assists infrastructure development here; it is not an application runtime dependency and does not itself run the Session Planning Agent.

## Troubleshooting

| Symptom | Action |
|---|---|
| Docker CLI works but Terraform fails to connect | Export DOCKER_HOST from the verified local context, then relaunch Claude from that terminal. |
| MCP disconnected | Check Docker engine, pull the pinned image, inspect `claude mcp get terraform`, restart Claude and use /mcp. |
| MCP server appears to wait when run manually | Stdio mode waits for protocol input. It is not an interactive shell; let Claude launch it. |
| Provider docs unavailable via MCP | Record the error; use the official provider docs as an explicitly identified fallback. |
| Port 8080 occupied | Set host_port=8081 in terraform.tfvars before planning; use the matching URL. |
| Container or network name collision | Use a new name consistently in this lab; do not delete someone else's resources. |
| Bind mount denied on Mac | Put the extracted project under your home directory and check Docker Desktop file-sharing settings. |
| Docker socket permission denied on Linux | Follow Docker's documented local engine setup. Do not chmod the socket world-writable. |
| Corporate TLS errors | Configure the approved CA according to your organisation and HashiCorp documentation; do not disable TLS verification. |
| Pull/init unavailable | Check internet, proxy and registry access before the session; warm caches during rehearsal. |
| Plan says state changed | Regenerate the plan and review it; do not force an obsolete plan. |

## Rehearsal checklist

- [ ] Record `terraform version`, `claude --version`, Docker version and selected context.
- [ ] Confirm actual Terraform MCP lookup and save non-sensitive evidence.
- [ ] Run init, fmt check, validate and plan successfully.
- [ ] Optionally deploy, check health and verify a no-change plan.
- [ ] Try the port change and cleanup.
- [ ] Retain the provider lock file and known-working MCP version.
- [ ] Share source/configuration only; exclude state, binary plans, plan JSON and secrets.
- [ ] Tell attendees that Claude access and local Docker setup are prerequisites.

## Suggested 90-minute session

10 min: responsibilities and application requirements. 15 min: setup and MCP lookup. 25 min: generate/review Terraform and validate. 15 min: plan inspection and optional apply. 15 min: infrastructure for an agentic application. 10 min: questions and cleanup.

## Official sources

Checked 19 November 2026. These are the upstream references to use if installation or tool schemas change.

- Terraform install: https://developer.hashicorp.com/terraform/install
- Claude Code installation: https://support.claude.com/en/articles/14552382-your-first-day-in-claude-code
- Claude Code MCP: https://code.claude.com/docs/en/mcp
- Terraform MCP repository and Docker invocation: https://github.com/hashicorp/terraform-mcp-server
- Local Terraform MCP and public registry access: https://developer.hashicorp.com/terraform/mcp-server/deploy/local
- Terraform MCP tool reference: https://developer.hashicorp.com/terraform/mcp-server/reference
- Docker provider: https://registry.terraform.io/providers/kreuzwerker/docker/4.6.0/docs
- HashiCorp Docker tutorial: https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build
- Terraform plan: https://developer.hashicorp.com/terraform/cli/commands/plan
- Docker Desktop for Mac: https://docs.docker.com/desktop/setup/install/mac-install/
