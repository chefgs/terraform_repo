# Terraform MCP Infrastructure Workshop

Process steps for Claude Code, GitHub Copilot and Codex

**Markdown edition — 19 November 2026**

**Reading order:** Complete sections 1–5 for the local lab. Use sections 8–10 for development practices and tests. Section 11 is the optional real-cloud workflow; it does not change the account-free workshop prerequisites.

**Execution boundary:** Commands in the base lab operate on Docker. Cloud commands and roles require a separately prepared cloud root module and authorised account; do not point the Docker lab at AWS and expect the same configuration to work.

Prepared for Saravanan Gnanaguru • CloudEngine Labs • HUG Accra

### Purpose and outcome

Choose one AI coding tool, connect the Terraform MCP Server, inspect provider documentation, develop Terraform configuration and review a real local infrastructure plan. Optional steps deploy a web container, verify it, change its port and clean up.

This lab requires no AWS or HCP Terraform account. It uses Docker on your laptop. Internet and access to your chosen AI tool are required. Plan-only participants can stop before deployment.

### What you will build

A local Docker network and nginx container serving a minimal Meeting Session Pulse landing page at localhost. The starter is an infrastructure foundation, not the complete polling application or an implemented AI agent.

### Use this document with the starter kit

The starter kit is in this repository, in the `terraform-mcp-workshop` folder. It includes infra/main.tf, site/index.html, site/health.json and CLAUDE.md. Keep the directory structure unchanged.

```bash
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo
git switch feature/mcp_workshop   # only until the branch is merged to main
```

Share the repository link with attendees ahead of the session.

### Process map

1 Prepare the local environment

2 Choose Claude Code Copilot or Codex and connect MCP

3 Verify an actual documentation lookup

4 Generate or review Terraform and validate

5 Create and explain a plan then stop or approve deployment

6 Verify change and clean up

7 Discuss infrastructure for an agentic application

### Verification status

Official setup documentation was checked on 19 November 2026. Codex MCP CLI syntax was checked with local help. This Markdown edition was converted from the reviewed process document and expanded with rationale and live-cloud checklists. The added test examples are illustrative and have not been executed here. The Docker and Terraform lab has not been executed end to end in this authoring environment; use the rehearsal checklist before presenting it as tested.

## 1 Prepare the environment

**Why we do this:** A known local runtime and Docker endpoint prevent connection failures and accidental changes on a remote engine. Keeping versions stable makes the workshop repeatable.

### Install the common prerequisites

**Why we do this:** Terraform executes IaC, Docker supplies the local infrastructure target, and your chosen agent coordinates development. Verify the engine before diagnosing agent or MCP problems.

macOS commands below assume Homebrew is installed. Install and start Docker Desktop for your Mac architecture. Linux attendees can use Docker Engine; Windows attendees should use WSL2 with Docker Desktop integration. Run all lab commands within one environment.

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
docker version
docker info
```

Success check: Terraform prints its version; Docker reports a working server as well as its client. Follow the official Docker installation link in the references if the engine is unavailable.

### Open the project

**Why we do this:** Terraform resolves files relative to its root module. The correct folder and local socket ensure the provider, terminal and agent operate on the same environment.

```bash
cd terraform_repo/terraform-mcp-workshop
pwd
ls
docker context show
docker context inspect --format '{{.Endpoints.docker.Host}}'
```

Adjust the folder path if you cloned elsewhere. Confirm the context points to a local Unix socket, not an SSH or TCP remote engine. Use docker context ls and docker context use YOUR_LOCAL_CONTEXT if necessary.

```bash
export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
docker info
docker pull hashicorp/terraform-mcp-server:1.4.1
```

Keep this terminal open. Launch your agent from it where possible. Each terminal running Terraform must use the same local endpoint. For VS Code, verify this export in its terminal too; a previously running editor may not inherit new environment variables.

### Understand the responsibilities

The coding agent reads requirements, edits files and coordinates checks. Terraform MCP retrieves registry documentation. Terraform CLI creates the plan and applies approved changes through the Docker provider. Docker runs the resources. In this lab, MCP does not execute Terraform CLI.

### Keep the scope controlled

Only registry tools are enabled. No Terraform token, cloud credentials or Docker socket mount is needed inside the MCP container. Use normal agent permissions and retain approval before apply or destroy. Published application ports stay bound to 127.0.0.1.

Version baseline: MCP image 1.4.1, Docker provider 4.6.0 and nginx image 1.28-alpine. These are selected lab versions, not claims that they are the latest. Retain the versions and generated lock file after a successful rehearsal.

## 2A Set up Claude Code

**Why we do this:** This connects Claude Code to the documentation tools while limiting this lab to public registry access.

Choose this path if you will use Claude Code in a local terminal. Complete only one tool setup path for your first rehearsal.

### Install and authenticate

**Why we do this:** The agent needs its own authenticated service access. That login is separate from Terraform, Docker or cloud-provider credentials.

```bash
brew install --cask claude-code
claude --version
claude
```

Complete sign-in using your supported Claude account or configured billing access. Exit the session, return to the project root and register MCP.

### Register the project server

**Why we do this:** Project-scoped registration makes this dependency explicit and reviewable without enabling it in every Claude project.

```bash
claude mcp add --transport stdio --scope project terraform -- \
  docker run -i --rm \
  hashicorp/terraform-mcp-server:1.4.1 \
  stdio --toolsets=registry
claude mcp list
claude
```

Project scope writes .mcp.json. If the server already exists, inspect it with claude mcp get terraform and preserve unrelated configuration. Approve the project and its MCP server when prompted.

### Check the connection

**Why we do this:** This catches launch and trust problems before you rely on documentation returned through MCP.

```text
/mcp
```

Run /mcp inside Claude Code, not in your shell. Confirm that terraform is connected and registry tools are available. A server listing alone is not proof of a successful tool call; complete the common lookup exercise in section 3.

### Apply the project instructions

**Why we do this:** Written project constraints keep the agent aligned on allowed resources, validation commands and approval boundaries. Instructions complement permissions; they do not enforce security by themselves.

Claude Code reads CLAUDE.md in the supplied kit. Verify the agent has read it before making changes. The file authorizes local edits, init, formatting, validation and plan, while reserving apply and destroy for approval.

### First message

**Agent prompt**

```text
Read CLAUDE.md and README.md. We are using only local Docker infrastructure. Confirm the working directory and local Docker endpoint. Discover the Terraform MCP registry tools and report connection status. Do not provision resources. I will give you the documentation lookup and infrastructure steps next.
```

### Success checkpoint

You should have a connected MCP server, acknowledged project instructions and no infrastructure changes. Continue with the common process in section 3.

## 2B Set up GitHub Copilot

**Why we do this:** Copilot must discover the MCP server in the configuration used by its active session. A correct JSON file in the wrong location will not supply tools to that session.

Use GitHub Copilot in a local VS Code workspace. Install VS Code and its GitHub Copilot integration, sign in and enable an agent session with tool access. This guide does not use GitHub’s hosted cloud coding agent.

### Configure MCP for the active session

**Why we do this:** The client needs a transport, executable and arguments to launch the server. Use the schema supported by the actual Copilot runtime.

Current Copilot sessions: open Chat Open Customizations from the Command Palette, choose MCP Servers and add the Docker launch command. The native workspace configuration is .mcp.json with a top-level mcpServers object. Merge this entry into an existing file rather than replacing other servers.

```json
{
  "mcpServers": {
    "terraform": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "hashicorp/terraform-mcp-server:1.4.1",
        "stdio", "--toolsets=registry"
      ],
      "tools": ["*"]
    }
  }
}
```

Older editor-managed Agent mode: use .vscode/mcp.json with the same entry under servers instead of mcpServers, and omit tools. Match the format to the active session; do not configure duplicate entries in both locations. The current native setup can also be added through the customization UI if its file picker differs.

### Verify and load instructions

**Why we do this:** A visible configuration does not prove tool access. Check the session and load the workshop rules before requesting edits.

Start or enable the server in the session’s MCP controls, approve trust if prompted and confirm its tools are available. Select Agent mode where your version offers it. Open the integrated terminal and verify docker info and DOCKER_HOST.

Create .github/copilot-instructions.md containing the workshop rules from CLAUDE.md. Alternatively, explicitly attach CLAUDE.md to the chat and request that it be read; do not assume Copilot automatically discovers that filename.

### First message

**Agent prompt**

```text
Read the workshop instructions and README.md. Use the Terraform MCP registry tools for documentation, and terminal tools for Terraform commands. Confirm this session can access the local Docker engine. Do not apply or destroy resources. Perform the common lookup exercise next and show the actual tool call.
```

Success checkpoint: an actual MCP call succeeds in this Copilot session. Then continue in section 3. UI labels vary by VS Code version; use the official MCP configuration reference if needed.

## 2C Set up Codex

**Why we do this:** Local Codex CLI can coordinate code edits and Terraform commands against your laptop. A remote agent session has a different filesystem and Docker endpoint.

Use Codex CLI locally so terminal commands can reach your laptop’s Docker engine. This process is not for a remote Codex web task, whose execution environment is separate from your laptop.

### Install and authenticate

**Why we do this:** The agent needs its own authenticated service access. That login is separate from Terraform, Docker or cloud-provider credentials.

```bash
brew install --cask codex
codex --version
codex
```

Complete sign-in using supported ChatGPT access or configured API billing. Exit the session and return to the project root.

### Register Terraform MCP

**Why we do this:** Registration lets Codex discover registry tools. Inspect scope because a user-level server is available beyond this one project.

```bash
codex mcp add terraform -- \
  docker run -i --rm \
  hashicorp/terraform-mcp-server:1.4.1 \
  stdio --toolsets=registry
codex mcp list
```

The CLI registration is normally user-scoped in ~/.codex/config.toml; do not assume it is restricted to this project. Inspect existing configuration before adding a duplicate. A trusted project can instead use .codex/config.toml with this server entry:

```toml
[mcp_servers.terraform]
command = "docker"
args = [
  "run", "-i", "--rm",
  "hashicorp/terraform-mcp-server:1.4.1",
  "stdio", "--toolsets=registry"
]
```

Choose one registration method. Preserve other configuration. Restart Codex after changes and confirm the server connects, then verify with a real lookup.

### Load project rules and start

**Why we do this:** AGENTS.md gives Codex persistent project context. Preserving existing instructions prevents the workshop from overwriting unrelated constraints.

```bash
cp CLAUDE.md AGENTS.md
codex
```

Run the copy only if AGENTS.md does not already exist; otherwise merge the workshop rules. Keep normal sandbox and approval settings. If Docker access is blocked, use the client’s supported permission flow or execute the reviewed commands manually in your local terminal. Do not disable all protections.

### First message

**Agent prompt**

```text
Read AGENTS.md and README.md. Confirm the local project and Docker endpoint. Discover Terraform MCP registry tools and show an actual provider documentation lookup. Use terminal tools for local Terraform commands. You may edit files and validate or plan, but stop for approval before apply or destroy.
```

Success checkpoint: actual documentation lookup works, and the terminal can access the local Docker engine. Continue with the common process in section 3.

## 3 Look up documentation and develop code

**Why we do this:** Ground generation in provider documentation, then review the proposed code before giving it execution access.

The remaining process is shared by all three tools. Prompts go into the agent chat; shell commands go into a local terminal at the project root.

### Step 1 Verify an actual MCP call

**Why we do this:** A model can produce a plausible answer from memory. Visible tool evidence distinguishes a real registry lookup from an unsupported claim.

**Agent prompt**

```text
Use the Terraform MCP registry tools to retrieve kreuzwerker/docker documentation for version 4.6.0 and the docker_image, docker_network and docker_container resources. Verify image_id, ports.ip, networks_advanced and read-only volume mounts. List the tools actually called and returned identifiers or URLs. If version-specific lookup fails, say so. Do not edit files yet.
```

Pass condition: visible MCP tool activity and relevant documentation. If Docker-provider retrieval fails, record the limitation and use its official registry pages as a disclosed fallback. You can separately verify MCP with an AWS provider documentation query; that does not verify Docker syntax.

### Step 2 Choose a review or generation exercise

**Why we do this:** Reviewing a supplied baseline gives a reliable first run; generating from requirements teaches how the agent turns intent into IaC. Both need an independent review.

First rehearsal: review the supplied infra/main.tf against the retrieved documentation. Ask the agent to explain resources, dependencies, localhost binding and the read-only mount, then make only required corrections.

For a fresh-generation exercise, work in a separate copy of the kit and move the starter aside:

```bash
mv infra/main.tf infra/main.tf.reference
```

**Agent prompt**

```text
Generate infra/main.tf without reading main.tf.reference first. Use kreuzwerker/docker 4.6.0, Terraform >=1.6 and <2.0, nginx:1.28-alpine, an image resource with keep_locally=true, network meeting-pulse-lab and container meeting-pulse-web. Reference image_id, attach the network, map port 80 to 127.0.0.1 using an integer host_port variable default 8080 and range 1024–65535. Mount ../site read-only at /usr/share/nginx/html using an absolute path derived from path.module. Output application_url. Inherit the local Docker endpoint. No cloud backend, provisioners or credentials. Use the MCP documentation and stop after generation.
```

Compare generated code with the reference. Terraform ignores the .reference extension. Do not keep both copies as .tf files, which would duplicate resource declarations.

### Step 3 Inspect before execution

**Why we do this:** Provider plugins, modules, data sources and helper commands can execute code or access services. Review the configuration and dependencies before even a plan.

Confirm only the intended local resources are declared. Inspect new files and commands. Reject unrequested cloud resources, remote Docker endpoints, secret values, broad host mounts and automatic apply.

The agent should distinguish verified provider syntax from assumptions. Record any fallback documentation so the session does not imply MCP succeeded when it did not.

## 4 Validate and create the plan

**Why we do this:** Static validation and planning catch different classes of error before resource changes are authorised.

### Step 4 Initialize and validate

**Why we do this:** Initialization installs declared dependencies; formatting reduces review noise; validation checks configuration consistency. None of these proves runtime correctness.

```bash
terraform -chdir=infra init
terraform -chdir=infra fmt
terraform -chdir=infra validate
terraform -chdir=infra fmt -check
```

Expected: provider installation and validation succeed. Keep the generated infra/.terraform.lock.hcl. Do not distribute the .terraform directory or local state.

**Agent prompt**

```text
Run init, fmt and validate using terminal tools. If a check fails, consult provider documentation, make the smallest correction and rerun the failed check. Report actual output. Do not change provider versions silently or apply resources.
```

### Step 5 Generate and inspect the plan

**Why we do this:** The plan reveals the actual proposed resource actions for the current inputs and state, allowing review before execution.

```bash
terraform -chdir=infra plan -out=demo.tfplan
terraform -chdir=infra show -no-color demo.tfplan
terraform -chdir=infra show -json demo.tfplan > infra/plan.json
```

Fresh state and the unchanged starter should propose three creations: an image, network and container. Read actual results rather than assuming the count. Some values remain known only after apply.

**Agent prompt**

```text
Read infra/plan.json. Explain each proposed action, dependencies, published port and host mount. Identify replacements, deletions and unknown values. Separate what the plan checks from runtime health and image-pull success, which have not been tested. Stop for review.
```

### Plan only stopping point

**Why we do this:** Attendees can complete the core learning objective without starting the application container.

You have now demonstrated MCP documentation retrieval, AI-assisted Terraform development, validation and a real local Docker plan. You can stop here without creating the application container.

Terraform plan previews resource changes; there is no separate terraform dry-run command. Planning can contact the Docker engine, while init and saved plans write local files. This is not an AWS plan or a complete proof that deployment will succeed.

### Record evidence

**Why we do this:** A recorded command result and plan summary make claims reviewable. Keep sensitive artifacts restricted rather than copying them into AI conversations or public repositories.

Save non-sensitive screenshots or notes of the MCP call, validation result and plan summary for your rehearsal. Keep state, binary plans, plan JSON and credentials out of Git and attendee materials. Commit source and the provider lock file only after reviewing them.

## 5 Optionally deploy change and clean up

**Why we do this:** The optional lifecycle exercise checks whether planned infrastructure can actually run and whether changes and cleanup remain controlled.

### Step 6 Approve and apply

**Why we do this:** An apply changes resources. Reviewing the exact plan separates the agent’s proposal from the engineer’s execution decision.

Review the exact saved plan before running the next command. Applying a saved plan does not ask the usual yes/no question; executing it is the approval. Regenerate the plan if configuration or state has changed.

```bash
terraform -chdir=infra apply demo.tfplan
terraform -chdir=infra output -raw application_url
curl --fail http://127.0.0.1:8080/health.json
docker ps --filter name=meeting-pulse-web
```

Open http://127.0.0.1:8080 and confirm the landing page. The health route checks static web serving only; no database or agent is present.

```bash
terraform -chdir=infra plan -detailed-exitcode
```

Exit 0 means no changes, 2 means changes are proposed, and 1 means an error. After a successful unchanged deployment, expect 0.

### Step 7 Review a port change

**Why we do this:** A small change shows whether the provider updates or replaces a resource, and makes interruption and persistence implications visible.

```bash
printf 'host_port = 8081\n' > infra/terraform.tfvars
terraform -chdir=infra plan -out=change.tfplan
terraform -chdir=infra show -no-color change.tfplan
```

This creates or replaces the demo tfvars file; merge the value instead if you already have other settings. Ask the agent to explain any container replacement, retained resources and interruption. Apply only after review:

```bash
terraform -chdir=infra apply change.tfplan
curl --fail http://127.0.0.1:8081/health.json
```

### Step 8 Clean up the lab

**Why we do this:** Removing managed resources verifies lifecycle ownership and prevents leftover services. Keeping state until cleanup preserves Terraform’s resource tracking.

```bash
terraform -chdir=infra plan -destroy -out=cleanup.tfplan
terraform -chdir=infra show -no-color cleanup.tfplan
```

Confirm only lab resources are targeted. After approval:

```bash
terraform -chdir=infra apply cleanup.tfplan
docker ps -a --filter name=meeting-pulse-web
docker network ls --filter name=meeting-pulse-lab
```

Container and network should be absent. keep_locally=true retains the nginx image cache. The MCP image and site files also remain. Never use docker system prune as workshop cleanup or delete state before destroying managed resources.

## 6 Troubleshoot and rehearse

**Why we do this:** Rehearsal isolates installation, client configuration, permissions and provider failures before a live audience encounters them.

### Docker connection fails

Start the engine, inspect the selected context and export DOCKER_HOST from the verified local socket. Repeat in the terminal running Terraform. For VS Code, check the agent’s environment rather than assuming it inherited your shell. Do not connect to a remote engine by accident.

### MCP connection fails

Confirm Docker is running and the pinned image can be pulled. Inspect the client’s server configuration and restart the session. Stdio servers wait for protocol input when run manually; waiting alone is not a failure. Use -i, not -d or -t, for this MCP launch.

### Copilot does not see the server

Match configuration to the active runtime: native Copilot uses mcpServers in .mcp.json; older editor-managed mode uses servers in .vscode/mcp.json. Check the session’s MCP tools, not just the file. Avoid duplicate server definitions.

### Port or resource name is occupied

Set host_port=8081 before planning, or choose new lab resource names consistently. Do not stop or delete unrelated containers. Use the correct port for health checks.

### Mount or permission errors

On macOS, keep the project under your home folder and check Docker Desktop file sharing. On Linux, follow Docker’s supported socket permission setup. Do not make the socket world-writable. Handle agent sandbox restrictions with supported approval or manual terminal execution.

### Network or certificate errors

Check proxy, registry access and approved corporate CA configuration. Do not disable TLS validation. Warm image/provider caches before the workshop, while remembering that AI and MCP lookups still need network access.

### Rehearsal checklist

- [ ] Record tool versions and the local Docker context.

- [ ] Verify an actual MCP lookup in each client you intend to demonstrate.

- [ ] Run init, formatting check, validation and a fresh plan.

- [ ] If deploying, confirm the page, health response and no-change plan.

- [ ] Exercise a change and destroy the resources through Terraform.

- [ ] Retain the successful version pins and provider lock file.

- [ ] Share this document and the repository link without state or plans.

- [ ] Tell attendees to choose one agent and complete its login beforehand.

## 7 Extend to infrastructure for an agentic app

**Why we do this:** This connects the base infrastructure lab to the compute, state, tool access and observability needed by an agentic application without claiming that extension is already built.

This section is an architecture discussion after the base demo. It does not claim that the static page contains an AI agent.

### Product extension

A Session Planning Agent reads aggregate poll responses, searches an approved workshop catalogue, checks prerequisites and drafts a next-session agenda for an organiser to review. Tool selection and multi-step work distinguish this from a single summarisation prompt.

### Infrastructure decisions to explain

- [ ] API and agent worker: keep web requests separate from longer planning tasks when needed.

- [ ] Model endpoint: use hosted inference or a separately managed local runtime; a hosted-model client does not inherently need a GPU.

- [ ] State and persistence: store polls, job status, checkpoints and generated agendas.

- [ ] Queue: introduce asynchronous dispatch and bounded retries when the workload justifies them.

- [ ] Tool permissions and secrets: grant narrow access and inject credentials at runtime.

- [ ] Observability: trace model calls, tool actions, latency, failures and usage.

- [ ] Application controls: implement timeouts, retry limits, evaluations and human review in the appropriate runtime and workflow. Terraform alone does not supply these behaviours.

### Architecture prompt for any of the three tools

**Agent prompt**

```text
Propose an infrastructure extension for a Session Planning Agent that reads poll aggregates, searches an approved catalogue, checks prerequisites and drafts an agenda. Separate application code, Terraform-managed resources, runtime secrets and agent controls. Explain what is required now versus optional as load grows. Verify relevant provider resources using Terraform MCP. Produce a diagram and backlog only; do not provision anything or claim the extension works.
```

### Framing for the audience

We will use Terraform MCP to develop and review infrastructure configurations, then explore how the architecture expands to support an agentic application. The MCP server assists development; it is not a runtime dependency of the Session Planning Agent.

## Original references and completion record

Official sources checked on 19 November 2026. Client interfaces evolve; verify the chosen path during rehearsal and keep the demonstrated versions stable for the event.

Terraform installation
https://developer.hashicorp.com/terraform/install

Terraform MCP source and client examples
https://github.com/hashicorp/terraform-mcp-server

Local MCP setup and registry access
https://developer.hashicorp.com/terraform/mcp-server/deploy/local

Docker provider reference
https://registry.terraform.io/providers/kreuzwerker/docker/4.6.0/docs

Terraform Docker tutorial
https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build

Terraform plan
https://developer.hashicorp.com/terraform/cli/commands/plan

Claude Code setup
https://support.claude.com/en/articles/14552382-your-first-day-in-claude-code

Claude Code MCP
https://code.claude.com/docs/en/mcp

Copilot MCP configuration
https://code.visualstudio.com/docs/agents/reference/mcp-configuration

Codex installation
https://github.com/openai/codex

Codex MCP
https://learn.chatgpt.com/docs/extend/mcp?surface=cli

Docker Desktop for Mac
https://docs.docker.com/desktop/setup/install/mac-install/

### Record your rehearsal

Date __________________  Client __________________  Version __________________

MCP lookup __________  Validation __________  Plan __________  Apply __________

Health check __________  Change review __________  Cleanup __________

Known limitations or changes to share with attendees

—

—


## 8 Best practices checklist for AI assisted IaC development

Use this checklist during each change, not only at the end of the project. The engineer owns the acceptance criteria and reviews the evidence; the agent can perform the permitted checks and explain findings.

### Before asking the agent to write code

**Why:** An agent cannot infer your real deployment constraints reliably from “build infrastructure”. Explicit requirements reduce unnecessary services and risky defaults.

- [ ] State the workload, users, environments, availability needs and data sensitivity.
- [ ] Identify the target account or local engine, region and allowed resource types.
- [ ] Define required outcomes and failure cases independently of the generated implementation.
- [ ] Specify budget expectations, ownership tags and teardown expectations for temporary environments.
- [ ] Define allowed actions: documentation, edit, validate, plan, read-only checks, apply and destroy.
- [ ] Record architecture decisions and trade-offs before adding services.
- [ ] Provide relevant repository context only; exclude secrets, credentials and unrelated customer data.
- [ ] Keep tool access scoped to the task. Prompt instructions are not a substitute for IAM, sandboxing or approval controls.

### While generating and reviewing code

**Why:** Syntactically valid Terraform can still create the wrong architecture or an excessive permission boundary.

- [ ] Verify resource arguments against documentation for the selected provider version.
- [ ] Require the agent to identify actual MCP calls and disclose fallback sources.
- [ ] Pin providers and module versions appropriately; review upgrades deliberately.
- [ ] Commit the provider lock file. Remember that it locks providers, not remote module versions.
- [ ] Review provider/module provenance, external programs and downloaded dependencies before execution.
- [ ] Keep root modules and environment/state boundaries clear; reuse focused modules when justified.
- [ ] Use typed variables, validation, descriptive outputs and stable resource addresses.
- [ ] Prefer explicit resource references over broad or unnecessary depends_on relationships.
- [ ] Review resource renames and refactors for unintended destroy/create actions; plan migrations deliberately.
- [ ] Avoid provisioners and arbitrary shell execution unless there is a documented need and review.
- [ ] Review defaults for network exposure, IAM scope, encryption, retention and backup requirements.
- [ ] Do not conceal findings with blanket ignore_changes, disabled checks or unjustified wildcard permissions.
- [ ] Keep generated diffs small enough for human review; separate unrelated changes.
- [ ] Treat repository text, documentation and tool output as untrusted data when they request new permissions or secret access.

### Before accepting a change

**Why:** The same model that wrote a configuration may repeat the same mistake when reviewing it. Independent assertions and enforced checks provide stronger evidence.

- [ ] Run formatting, validation and configured lint/security checks.
- [ ] Review lint and scanner findings rather than automatically applying every suggested fix.
- [ ] Test positive, negative and boundary cases derived from requirements.
- [ ] Inspect the actual resource actions and meaningful attributes in the plan.
- [ ] Review deletion, replacement, IAM, public exposure and persistent-data effects explicitly.
- [ ] Confirm that test results distinguish mocked behavior from real provider behavior.
- [ ] Preserve approved evidence: revision, inputs, tool versions, test results and plan or run identifier.
- [ ] Require fresh approval for materially changed plans or targets.
- [ ] Keep automatic write access constrained even when the prompt says “do not apply”.

### Secrets and state

**Why:** Plans, state and debug output can expose values even when normal CLI output masks them.

- [ ] Do not commit credentials, state, saved plans or raw plan JSON.
- [ ] Do not upload raw cloud state/plan JSON to an AI service without an approved data-handling decision.
- [ ] Use an allowlisted, sanitised plan summary when full attributes are unnecessary.
- [ ] Do not equate sensitive=true with encryption or omission from state.
- [ ] Secure backend access, encryption, locking and recovery for shared environments.
- [ ] Keep backend credentials out of static backend configuration and command arguments where they may be persisted.
- [ ] Do not enable verbose provider logs containing secrets as a default troubleshooting step.

See [HashiCorp sensitive data guidance](https://developer.hashicorp.com/terraform/language/manage-sensitive-data) and [state guidance](https://developer.hashicorp.com/terraform/language/state).

## 9 Know what each test proves

**Why:** Validation, mocks, planning and runtime tests provide different evidence. Passing one layer does not replace the others.

| Layer | What it checks | What it does not establish | Resource mutation |
|---|---|---|---|
| Format and validate | Formatting, configuration consistency and provider schema compatibility | Cloud permissions or application behavior | No intended infrastructure changes; init downloads code |
| Lint and static security checks | Known code patterns, conventions and policy violations | Complete security or deployment success | Normally none; inspect configured plugins/helpers |
| Mock-provider tests | Configuration decisions and assertions under simulated provider values | Real API behavior, permissions, quotas or availability | No real resources for fully mocked providers |
| Real provider plan tests | Proposed changes using actual provider context | Successful creation or runtime health | No intended resource creation for plan runs; external programs or provider actions require scrutiny |
| Live integration tests | Creation and behavior in an isolated real environment | Production capacity or resilience unless tested | Yes, potentially billable |
| Smoke and negative-access tests | Endpoint health, key user flow and denied access cases | All failure modes | Reads plus explicitly approved test writes |
| Load or failure tests | Performance or recovery within a controlled scenario | Behavior beyond the scenario | Can disrupt services and increase costs |

Terraform tests can execute apply operations. Inspect every run block and provider before running terraform test; use explicit command = plan when that is the intended boundary. A mocked provider does not make other real provider aliases in the same suite harmless. See the [test command reference](https://developer.hashicorp.com/terraform/cli/commands/test).

## 10 Add a focused local infrastructure test

### Step 1 Define the requirements before the test

**Why:** Tests should protect an intended behavior rather than simply restating generated code.

For this workshop, useful requirements are:

- The published web port must bind only to localhost.
- A requested host port must reach the planned container port mapping.
- A port below 1024 must fail input validation.

### Step 2 Add a mocked plan test

**Why:** This checks configuration logic without creating a Docker container. It does not prove nginx will start or Docker accepts the configuration at runtime.

Use Terraform **1.7 or newer** for provider mocking. Update the root version constraint to `>= 1.7.0, < 2.0.0` for this exercise; the base lab's older minimum is not sufficient for mocks. Keep the chosen Docker provider version.

From the project root:

```bash
mkdir -p infra/tests
```

Create `infra/tests/local_contract.tftest.hcl`:

```hcl
mock_provider "docker" {}

run "localhost_and_port_contract" {
  command = plan

  variables {
    host_port = 8081
  }

  assert {
    condition = alltrue([
      for port in docker_container.web.ports :
      port.ip == "127.0.0.1"
    ]) && length(docker_container.web.ports) == 1
    error_message = "Exactly one port must be published on localhost."
  }

  assert {
    condition = anytrue([
      for port in docker_container.web.ports :
      port.internal == 80 && port.external == 8081
    ])
    error_message = "Host port 8081 must map to web port 80."
  }
}

run "reject_privileged_host_port" {
  command = plan

  variables {
    host_port = 80
  }

  expect_failures = [var.host_port]
}
```

This example targets the starter's `docker_container.web` resource and `host_port` variable. If the agent renamed either, reconcile the names before running. Do not weaken the assertions to hide a real mismatch.

### Step 3 Inspect and run only this test file

**Why:** Filtering prevents accidentally running an unrelated apply-based test suite.

```bash
terraform -chdir=infra init
terraform -chdir=infra fmt -recursive
terraform -chdir=infra validate
terraform -chdir=infra test -filter=tests/local_contract.tftest.hcl
```

Expected: both runs pass; the invalid input is an expected failure. This is an illustrative unexecuted test example, so validate the provider schema and actual output during rehearsal. No real cloud credentials are needed. Provider installation may still require network access.

### Agent prompt for test development

```text
Derive test cases from the stated requirements before inspecting the code.
Review the mocked test file and identify every provider and command mode.
Run only the named mock test after confirming no real provider is configured.
If it fails, distinguish a wrong implementation, a wrong assertion, and an
unsupported test assumption. Do not delete checks or widen permissions to
make tests pass. Report commands, results and remaining untested behavior.
```

Provider mocking is documented in [HashiCorp's mocking guide](https://developer.hashicorp.com/terraform/language/tests/mocking).

## 11 Real cloud development and testing checklist

This is an **optional live-operation checklist**, not a prerequisite for the local workshop. Use a separately reviewed cloud configuration with an authorised sandbox account. It is not a ready-made AWS implementation: account IDs, roles, remote backend and workload-specific tests must be supplied for your environment.

Use one execution owner: local CLI, CI, or HCP Terraform. Do not have an agent and a pipeline independently apply the same state.

### Gate 1 Agree on scope and a test environment

**Why:** A real provider can create billable resources and affect existing data. Isolation makes failures recoverable.

- [ ] Confirm the cloud account/subscription/project, region and environment in writing.
- [ ] Use a dedicated sandbox with no production data or production connectivity unless explicitly required and approved.
- [ ] List allowed resource types and explicitly excluded services.
- [ ] Define budget alerts, expected duration and resource limits; alerts are not hard spending caps.
- [ ] Set owner, purpose, environment and expiry tags. Expiry tags alone do not delete resources.
- [ ] Define what must be preserved and who will perform cleanup if the session fails.
- [ ] Document the test plan, allowed test writes and stopping conditions.

**Exit evidence:** target identity, scope, owner, expected cost drivers and cleanup plan are recorded.

### Gate 2 Authenticate and prove the target identity

**Why:** Account identity must be verified where commands execute, not inferred from a profile name in a prompt.

- [ ] Prefer short-lived SSO/session credentials for developers and workload identity/OIDC for CI or remote execution.
- [ ] Keep credentials out of chat, generated files and command history.
- [ ] Verify the authenticated principal, account and region in the execution environment before plan and again before write operations if the session changes.
- [ ] Check provider aliases and assume-role settings; the caller used for a preliminary identity check may differ from a provider's final assumed role.
- [ ] Scope planning, applying and testing permissions to necessary operations and resources.
- [ ] Restrict state backend permissions independently from resource permissions.
- [ ] Never automatically grant administrator access after a permission error; inspect the denied action and request only the justified permission change.

**Exit evidence:** target matches the approved account and role; no credential values are included in the evidence.

### Gate 3 Configure the execution and state boundary

**Why:** Team workflows need consistent state ownership, locking and a recoverable history.

- [ ] Select the correct root module, backend, workspace/state key and region.
- [ ] Confirm backend encryption, access control, locking and recovery/versioning support.
- [ ] Use separate state and access boundaries for sandbox and production. A workspace name alone is not a security boundary.
- [ ] Confirm existing resources are managed intentionally; do not silently import or overwrite them.
- [ ] Review backend migration or state changes as separate operations.
- [ ] Keep bootstrap infrastructure for credentials/backends separate from a routine agent application change.
- [ ] Confirm no other process is applying to the same state.

**Exit evidence:** approved backend and execution owner are identified.

### Gate 4 Run static checks and nonmutating tests

**Why:** Cheap checks should catch defects before a real deployment attempt.

- [ ] Review all providers, modules, external data sources, helper programs and action triggers before initialization/planning.
- [ ] Run format, validate and configured lint/security policies.
- [ ] Run filtered mock tests and inspect their provider mappings.
- [ ] If using real-provider plan tests, confirm all run blocks explicitly use plan and review all dependencies for side effects.
- [ ] Check region support, quotas, naming constraints and required API enablement where relevant.
- [ ] Do not assume a plan is harmless if the configuration invokes external scripts or other side-effecting integrations.

**Exit evidence:** actual results are captured; failures and skipped checks are visible.

### Gate 5 Review the exact cloud plan

**Why:** A reviewed code diff does not reveal every replacement or permission effect produced by a provider.

- [ ] Generate a fresh plan against the approved account, state and inputs.
- [ ] Review create, update, replace and delete actions, including data-retention effects.
- [ ] Inspect IAM changes, public endpoints, ingress/egress and encryption settings.
- [ ] Review expensive services, continuously running compute, data transfer, logs and storage costs.
- [ ] Have the agent produce a concise risk summary from approved/sanitised evidence.
- [ ] Retain the source revision, lock file, variable set/version, policy results and plan/run identifier.
- [ ] Obtain approval for the exact plan. Re-plan after relevant code, state or input changes.

**Exit evidence:** named reviewer and approved immutable plan artifact or HCP run ID.

For an already prepared AWS or other cloud root module, these are command patterns, not instructions to run in the Docker root:

```bash
# Execute inside the reviewed cloud root with authorised credentials.
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=reviewed.tfplan
terraform show -no-color reviewed.tfplan
# Pause for review. Do not publish the plan or raw JSON.
```

### Gate 6 Apply once and observe completion

**Why:** Retrying blindly after an error can create confusing partial state or repeated side effects.

- [ ] Execute only through the approved owner and identity.
- [ ] For local/CI saved-plan execution, apply the approved artifact; for HCP Terraform approve the reviewed run.
- [ ] Remember that applying a saved plan does not add another interactive yes/no prompt.
- [ ] Observe final status, provider errors and partially created resources.
- [ ] On failure, inspect the actual state before retrying. Do not automatically destroy or roll back.
- [ ] Keep audit logs and record the run identifier and resource outputs without secrets.

```bash
# Only after approval of this exact saved plan:
terraform apply reviewed.tfplan
```

**Exit evidence:** successful execution, or a documented partial-failure assessment with next steps.

### Gate 7 Let agents run bounded infrastructure tests

**Why:** Successful provisioning confirms API operations, not that the application is usable or protected correctly.

- [ ] Verify expected resource configuration through cloud APIs, not only Terraform output text.
- [ ] Check health endpoints with bounded timeouts and retry counts.
- [ ] Exercise one approved user flow with synthetic data.
- [ ] Check persistence where required, including an approved restart/replacement scenario.
- [ ] Test that unauthorised requests are denied using a deliberately restricted test identity.
- [ ] Verify log/metric delivery and that logs do not expose test credentials or sensitive data.
- [ ] Evaluate network restrictions from an appropriate test location; a failure from one laptop is not proof of global inaccessibility.
- [ ] Run a no-change plan after the environment settles and investigate unexpected drift.
- [ ] Keep load tests, fault injection, destructive tests and broad network scans outside ordinary smoke testing unless separately scoped.
- [ ] Limit agent retries and stop on account mismatch, unexpected spend, data loss risk or policy failure.

**Exit evidence:** requirement → check → actual result → evidence → unresolved issue. Do not label all checks “passed” merely because apply succeeded.

### Gate 8 Clean up temporary test infrastructure

**Why:** Test cleanup can fail even when functional tests finish, leaving resources and charges behind.

- [ ] Inspect any terraform test cleanup diagnostics and list residual resources.
- [ ] For ordinary sandbox deployments, review a destroy plan against the correct state.
- [ ] Preserve required data and test evidence before authorised deletion.
- [ ] Verify removal through cloud APIs; include dependent artifacts such as snapshots, volumes, IPs and logs according to their retention policy.
- [ ] Retain state/recovery information until cleanup is verified.
- [ ] Revoke or let temporary credentials expire and remove unneeded grants.
- [ ] Record residual resources, owner and follow-up date; check delayed cost reporting later.

Do not treat a Terraform test's isolated state as complete protection: explicit names, data sources, external commands and permissions can still reach shared resources. Tests attempt cleanup, but that attempt is not a guarantee. See [Terraform test cleanup guidance](https://developer.hashicorp.com/terraform/cli/commands/test).

### Gate 9 Promote through the normal delivery process

**Why:** A sandbox success does not authorise deployment to production.

- [ ] Review the PR, requirements, policy results and operational evidence.
- [ ] Generate a new target-environment plan; never reuse a sandbox saved plan for production.
- [ ] Confirm production identity, state boundary, backup/recovery, rollout and incident ownership.
- [ ] Use the required production approval and observation process.
- [ ] Record residual risk and monitoring rather than claiming complete safety from a finite test suite.

## 12 Optional HCP Terraform and MCP integration

**Why:** HCP Terraform can centralise runs, state and approvals, while MCP can expose selected workspace/run operations to an agent. These are separate from local registry-only lookup.

- [ ] Keep the local workshop's registry-only configuration unchanged unless you intentionally add operational access.
- [ ] Discover the actual server tools and deployment limitations before designing an operational workflow.
- [ ] Treat the HCP Terraform token as separate from AWS credentials; it grants access to Terraform organisations/workspaces, not direct cloud authentication.
- [ ] Scope the token and workspace/team permissions to the intended environment.
- [ ] Set up HCP-to-cloud workload identity with narrowly scoped trust conditions for organisation, project, workspace and run phase where applicable.
- [ ] For AWS, consider separate planning and applying roles with justified permissions.
- [ ] Keep auto-apply disabled for this workshop workflow and retain approval on the reviewed run.
- [ ] If VCS changes trigger a run, inspect that run rather than also creating an unnecessary duplicate through MCP.
- [ ] Confirm the exact configuration revision is available remotely; an MCP run request does not upload uncommitted local files.
- [ ] Treat fetched run logs and plan data as potentially sensitive before sending them to an AI service.

AWS dynamic credentials reference: [HCP Terraform AWS configuration](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/aws-configuration). Tool availability reference: [Terraform MCP server](https://developer.hashicorp.com/terraform/mcp-server/reference).

## 13 Reusable agent prompt for a real cloud change

Fill the placeholders before use. This is a task boundary, not a replacement for platform permissions.

```text
Task: develop and test this IaC change in the authorised sandbox only.

Target account/project: <verified identifier>
Region: <region>
Root module and state/workspace: <exact values>
Execution owner: <local CLI, CI, or HCP Terraform>
Allowed services and resource scope: <scope>
Required behavior and acceptance tests: <requirements>
Cost expectations and maximum test duration: <limits>
Test data: synthetic only
Cleanup owner: <owner>

First verify repository instructions, target identity, provider aliases,
state boundary and the current source revision. Retrieve relevant provider
documentation through Terraform MCP and disclose unsuccessful lookups.

You may inspect code, propose edits and run the explicitly approved static,
mock and plan checks. Inspect providers, test commands and helper programs
before executing them. Do not assume terraform test is read-only.

Prepare a reviewable plan summary with resource actions, IAM/network/data
changes, cost drivers, test results, assumptions and unresolved concerns.
Use sanitised evidence; do not paste secrets, full state or raw sensitive
plan JSON into chat.

Stop for approval before apply, live apply-based tests, destroy, state
migration, privilege expansion or destructive tests. Bind approval to the
exact plan/run and target. After approval, execute only the authorised scope,
run bounded acceptance checks and report actual results.

If a step fails, inspect partial state and evidence. Do not disable checks,
expand permissions, repeat writes indefinitely or claim a rollback happened.
Propose the smallest justified next action and request the required decision.
```

## 14 Live development tracking sheet

Copy this table into the PR or rehearsal notes. Complete it as work proceeds.

| Stage | Owner | Actual result | Evidence or run ID | Approved next action |
|---|---|---|---|---|
| Requirements and target confirmed | | | | |
| Identity and state verified | | | | |
| MCP documentation retrieved | | | | |
| IaC changes reviewed | | | | |
| Static checks and mocks | | | | |
| Cloud plan and policy review | | | | |
| Apply authorised | | | | |
| Deployment observed | | | | |
| Runtime and negative tests | | | | |
| Drift checked | | | | |
| Cleanup or handoff verified | | | | |

Use explicit statuses: **not run**, **passed**, **failed**, **blocked**, or **not applicable with a reason**. A suggested test is not an executed test.
