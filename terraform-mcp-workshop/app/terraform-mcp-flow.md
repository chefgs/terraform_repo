# Application first, then Terraform with MCP

The infrastructure you need depends on the application you are deploying. So the first prompt to an AI tool must describe the application, and the architecture is drafted and approved by a human before any Terraform is written.

This document uses the Meeting Session Pulse poll in this folder as the example. It covers the architecture and the Terraform-with-MCP approach only, and it includes a worked example with real tool output. **No infrastructure is created for this app, and nothing here is ever applied.** The furthest this flow goes is a dry-run plan. The static lab (`infra/`, `site/`, the README and the slides) is unchanged and separate.

## Skim path

| Time you have | Read |
|---|---|
| 2 minutes | "The flow" and "What the app facts mean for the architecture". |
| 5 minutes | Add section 1 (the brief) and the worked example, step 2 (the architecture draft). |
| 15 minutes | Add section 3 (the review checklist), section 4 (the IaC prompt) and the worked example, step 4 (the lookups). |
| 30 minutes | Run the app, then do sections 1 to 4 live in Claude Code. |

## Before you start

Run the app from the workshop folder (the one that holds `CLAUDE.md`). Nothing to install:

```bash
python3 app/server.py                      # http://127.0.0.1:8000, Ctrl+C to stop
python3 -m unittest app/test_server.py     # 20 tests
```

Install, API, data and troubleshooting details are in [README.md](README.md).

The workshop folder ships a `.mcp.json` that registers the Terraform MCP server, so check it:

```bash
claude mcp list
claude
```

Then, inside Claude Code, run `/mcp` and check that `terraform` is connected. `CLAUDE.md` applies: local only, no cloud credentials, no apply without asking.

In a fresh folder with no `.mcp.json`, register the server first (the same command as slide 12 of the session slides):

```bash
claude mcp add --transport stdio --scope project terraform -- \
  docker run -i --rm \
  hashicorp/terraform-mcp-server:1.4.1 \
  stdio --toolsets=registry
```

## The flow

```
1 Brief          2 Architecture      3 Human review     4 IaC approach       5 After approval
(what the app    (diagram, why       (approve or send   (MCP lookups,        (write, validate,
 is and needs)    each part)          back)              resources named)     plan, gates)
      |                |                   |                   |                    |
  you write        AI drafts,           you decide        AI cites docs,        not done in
  the facts        no code yet          GATE              no files yet          this document
```

Two rules hold the flow together:

- **The prompt carries the application details.** An AI tool that is only told "make a Terraform for a web app" will guess the app, and then it designs infrastructure for the guess.
- **No Terraform before the architecture is approved.** A diagram is cheap to correct. Code built on a wrong architecture is not.

## 1. Write the application brief

Fill this in before the first prompt. Anything you do not know goes under "not decided", so the AI asks instead of guessing.

```text
Application brief
- Name and purpose:
- Users, and how many at the same time:
- Parts that exist today (page, API, jobs):
- Data: what is stored, how it grows, how long it is kept, who may see it:
- Traffic: reads versus writes, peak:
- Availability: what happens if it is down for an hour:
- Security: who may reach it, how they sign in, which secrets exist:
- Where it runs, who pays, budget limit:
- Constraints: regions, tools we must or must not use:
- Not decided yet (ask me, do not guess):
```

### The brief for the poll

Facts marked **code** are read from the files in this folder. Everything marked **assumption** is not in the code and the owner must confirm it.

```text
Application brief
- Name and purpose: Meeting Session Pulse. One question ("How useful was this
  session?") with four fixed answers. People vote and see the counts. [code]
- Users: session attendees. How many, and how many at once: assumption, owner
  to confirm. Nothing in the code limits it.
- Parts: one Python process (app/server.py) serves the page (GET /) and a JSON
  API: GET /api/health, GET /api/poll, POST /api/votes. No other services. [code]
- Data: one SQLite file, one table "votes" (id, option, created_at). One row per
  vote, no user identity stored. Retention and who may see results: assumption,
  owner to confirm. [code for the schema]
- Traffic: reads and writes are tiny. Votes are capped at 1024 bytes each. Peak
  rate: assumption, owner to confirm. [code for the cap]
- Availability: assumption: a workshop-length poll, brief downtime is acceptable.
  Owner to confirm.
- Security: no sign-in, and no check on who votes or how often, so one person can
  vote many times. No secrets today. It binds to 127.0.0.1 only. [code]
- Where it runs and budget: assumption: local only for the workshop. No budget set.
- Constraints: the workshop rules in CLAUDE.md. No cloud credentials. [CLAUDE.md]
- Not decided yet: public internet access, authentication, how long votes are
  kept, any backup.
```

## 2. Ask for the architecture first

```text
Using only the application brief below, propose an architecture.
Give me: a text diagram; a table of components with the brief fact that
requires each one and one alternative you considered; the path of one vote
through the system; what you would deliberately not add and why; risks; and
open questions. Where the brief does not say, ask instead of assuming.
Do not write Terraform, create files or call any tools yet. Stop for review.

<paste the brief here>
```

Result for the poll: see "Worked example", step 2.

## What the app facts mean for the architecture

| Fact in the brief | What it forces or rules out |
|---|---|
| One process serves the page and the API | One small compute unit is enough. A separate web server is optional, not required. |
| SQLite is a single file, one writer at a time | **One API instance is the simple, safe choice.** Several instances on one host sharing the same file also work: we ran two against one file, 40 votes each at the same time, and all 80 were counted with no lock errors. They take turns on the write lock, so it does not scale writes. What breaks it is the file being on a network filesystem, shared across hosts, or each instance having its own volume (separate copies of the data). Either way the file needs persistent storage. |
| Votes live only in that file | The file is the data. Deleting the volume (for example `terraform destroy`) deletes every vote. Backup is "copy the file" and needs an owner. |
| No sign-in, no vote limit | Not safe for the public internet as is. Keep it private, or add authentication before exposing it. |
| Binds to 127.0.0.1 only | **A finding for the review.** Inside a container, 127.0.0.1 is not reachable through a published port, so containerising it needs a code change to make the bind address configurable. |
| Default port 8000, DB path from `PULSE_DB` | Inside a container, `PULSE_DB` must point at the mounted volume path, or votes are lost when the container is replaced. |

**MongoDB variant.** Easy to describe, larger to build: a second container, a credential (a secret that must stay out of Terraform state and git), a start-up order where the API waits for the database, and a Mongo driver the app does not have today (it is not in the Python standard library). In return, API instances could run on different hosts and share one database.

## 3. Human review gate

Approve the architecture only when you can answer yes to each:

- Every component traces to a fact in the brief. Nothing is there "just in case".
- The SQLite file limits (one volume, one host) and the persistent volume are stated.
- Someone owns the data loss story: what deletes it and how it is backed up.
- It says who can reach the app, and the answer matches the security facts.
- Any cost is named, with an owner.
- Open questions are answered or written down as decisions.

If not, send it back with the corrections. Do not move to the next step.

## 4. Ask for the Terraform approach, using MCP

Only after approval. Paste the brief and the approved architecture. This prompt asks for the approach, not for code:

```text
Read CLAUDE.md. The target for this workshop is local Docker with the
kreuzwerker/docker provider. Using the Terraform MCP registry tools, name the
provider resource that implements each component of the approved architecture,
and verify each one against provider documentation. Start with
get_latest_provider_version, then call search_provider_docs and
get_provider_details for every resource. Show me every tool call and the
documentation identifiers returned. If a resource is not documented, say so.
Give me: a table of component, resource and the brief fact it satisfies; what a
plan should show; what a plan cannot prove; and anything that needs my decision
(cost, exposure, data loss). Do not write files, run Terraform or apply.
Stop for review.

<paste the brief and the approved architecture here>
```

Why it looks like this:

- **MCP lookups per resource** make the AI cite current provider documentation instead of writing resource arguments from memory.
- **"Show every tool call"** is how you tell a real lookup from a confident answer.
- **"What a plan cannot prove"** keeps a valid plan from being mistaken for a working app.

Result for the poll: see "Worked example", step 4.

## 5. After approval (not done here)

This flow stops at a dry-run plan. It does not apply or destroy anything.

1. Write the Terraform in its own folder, never inside the static lab's `infra/`.
2. Run `init`, `fmt`, `validate`, then `plan -out`, and review the real plan. These change no running resource.
3. Stop there. An apply, if anyone ever wants one, is a separate human decision on cost and risk. Running an apply is the approval.
4. Several independent modules and several agents: see `docs/agentic-iac-development.md`.
5. Do not commit state, plans or secrets.

## Worked example

This is what steps 2 to 4 produced for the poll, so you can compare it with your own run. It was run on 2026-11-21 in one Claude Code session by the assistant, using the brief above and this session's Terraform MCP tools. Another run may word things differently, and the tool output is only as current as the registry on that day.

**This is not a human-reviewed run.** The assistant drafted the architecture and then ran step 4 itself, to capture real tool calls. The rule in this document, no step 4 before step 3 is approved, was broken on purpose for the example. Nothing was written and no Terraform was run.

### Step 2: the architecture draft

```text
Browser --HTTP--> 127.0.0.1:8000 on your machine (published port, local only)
                        |
                  API container: Python, 1 instance, serves the page and the API
                        |  file I/O at the path in PULSE_DB
                  Docker volume holding the SQLite file
```

| Component | Brief fact that requires it | Alternative considered |
|---|---|---|
| API container (one instance) | One process serves the page and the API. | nginx in front plus a separate API container. Not chosen: nothing in the brief needs it. |
| Python runtime image | The app is Python. | Build a custom image. Not chosen for now: a build step is more to explain and maintain. A public Python image with the app code mounted read-only follows the static lab's pattern. |
| Docker volume for the SQLite file | Votes live only in that file and must survive the container being replaced. | The container's own storage: simplest, but votes are lost when it is recreated. A host-folder bind mount: works locally, but ties the poll to one path on one machine. |
| Port published on 127.0.0.1 only | Local only, and the app has no sign-in. | Publishing on all interfaces. Rejected: it would expose an app with no protection. |

**One vote through the system:** the browser sends `POST /api/votes` to 127.0.0.1:8000, the published port forwards it to the container, `server.py` validates it and runs the `INSERT` into the SQLite file on the volume, and the reply carries the fresh counts.

**Deliberately not added:**

- nginx or any reverse proxy: no brief fact needs one.
- MongoDB or any second database: SQLite fits the data.
- A second API instance: no load figure asks for it.
- TLS: local only.
- Authentication: the app has none, so it stays reachable from localhost only.
- A dedicated Docker network: one container has nothing to connect to. Add one when a second container appears.

**Risks:**

1. `server.py` binds to 127.0.0.1, which is expected to be unreachable through a published port from inside a container. This is standard Docker behaviour and was not tested here. A code change is needed before it can run in a container.
2. Destroying the volume deletes every vote. No backup owner is named.
3. No sign-in and no vote limit, so repeated votes are possible.
4. The Python image name and tag are not chosen. A Docker Hub image is not covered by the Terraform registry tools.
5. The container user must be able to write to the volume path. Not checked.

**Open questions:** how many voters, and how many at once? Are votes kept after the session, and who backs them up? Will it ever be public? Which Python image tag, and does the app code get mounted or built into an image? Is a code change to make the bind address configurable acceptable?

### Step 3: the review gate

| Checklist item | Result |
|---|---|
| Every component traces to a brief fact | Yes, see the table. |
| SQLite file limits and persistent volume stated | Yes. |
| Someone owns the data loss story | **Open.** No owner or backup is named. |
| Who can reach the app | Yes: localhost only. |
| Cost named, with an owner | Local Docker has no cost. A cloud target would need an estimate first. |
| Open questions answered | **No.** Five are open. |

**Human approval: not given.** A real run stops here until you answer the open questions and approve.

### Step 4: the MCP lookups

Registry calls made, with the documentation identifiers returned (provider `kreuzwerker/docker`, version 4.6.0):

| Tool | Input | Returned |
|---|---|---|
| `get_latest_provider_version` | `kreuzwerker/docker` | 4.7.0 |
| `search_provider_docs`, then `get_provider_details` | `image` | doc 13459280 (`docker_image`). `registry_image`, doc 13459283, also matched and was not used. |
| `search_provider_docs`, then `get_provider_details` | `network` | doc 13459281 (`docker_network`) |
| `search_provider_docs`, then `get_provider_details` | `container` | doc 13459279 (`docker_container`) |
| `search_provider_docs`, then `get_provider_details` | `volume` | doc 13459287 (`docker_volume`), looked up earlier in the same session |

| Component | Resource | What the documentation shows that matters here | Brief fact it satisfies |
|---|---|---|---|
| Runtime image | `docker_image` | `name` is required. `keep_locally` keeps the image on destroy. The read-only `image_id` is what the container should reference. A `build` block exists, and the docs say it requires the Docker option "Use containerd for pulling and storing images" to be off. | One Python process. |
| Persistent data | `docker_volume` | `name`, `driver` (defaults to `local`), `labels`. | Votes must survive container replacement. |
| API container | `docker_container` | `image` and `name` are required. `ports` takes `internal`, `external` and `ip`, and **`ip` defaults to `0.0.0.0`**. `volumes` takes `volume_name`, `container_path`, `host_path` and `read_only`, and **`host_path` takes precedence over `volume_name`**. `env` is a set of `KEY=VALUE`. `command` is a list. `restart` defaults to `no`. `healthcheck` is a block, and **`wait = true` requires a healthcheck or the provider errors**. | One process, local only, a persistent file. |
| Network (optional) | `docker_network` | `name` is required. `internal` exists. | Not needed for one container. |

What the lookups changed in the plan for the poll:

- **Exposure:** because `ip` defaults to `0.0.0.0`, the container's `ports` block must set `127.0.0.1` explicitly, or the poll would be published on every interface.
- **Mount:** use `volume_name` for the data volume and do not also set `host_path`, since `host_path` would override it.
- **Image:** pull a public image and mount the app code read-only, rather than use `build`, which has a Docker-host requirement.
- **Health:** `wait` needs a healthcheck. The app's `GET /api/health` is the natural endpoint to check.

**What a plan should show (an expectation, not run):** three creations (`docker_image`, `docker_volume`, `docker_container`) with the network left out. The container's `ports` shows `ip = "127.0.0.1"`, and it mounts the volume and sets `PULSE_DB` to a path on it. Values such as the IDs and the image ID are known only after apply.

**What a plan cannot prove:**

- The image can be pulled.
- The app starts and listens on an address reachable through the published port (the bind finding).
- The SQLite file really lands on the volume and survives the container being replaced.
- The container user can write to the volume.
- The poll is healthy.

**Decisions for you:**

1. Accept a code change that makes the bind address configurable. It is needed before the app can run in a container.
2. Image approach: pull a Python image and mount the code read-only (no build), or build a custom image.
3. Data: accept that `destroy` deletes the votes, or name a backup and an owner.
4. Exposure: keep `127.0.0.1` only. The provider default would be all interfaces.
5. Provider version: stay on 4.6.0 (the workshop pin) or move to 4.7.0 (the latest returned).
6. Cost: none for local Docker. A real cloud target changes that, and needs an estimate and your approval first.

**Limits of this lookup:** the Terraform registry tools check provider documentation only. They do not check that a Docker Hub image name or tag exists, or that the app runs in a container.

## Verification status

**Run:**

- The 20 unit tests in `app/test_server.py` pass (Python 3.15.2, SQLite 3.54.1). They cover health, the page, counting, restart persistence, bad input, wrong content type, missing, bad and oversized `Content-Length`, a cut-off body, unknown path, wrong method and a database failure. Each failure test checks the exact message and that no generic wording appears.
- A real round trip with `curl` against a running server: health, two votes, one rejected vote, counts surviving a restart, and the process listening on 127.0.0.1 only.
- Two server processes on different ports sharing one database file, 40 votes each sent at the same time: all 80 returned 201, both reported a total of 80, and no lock errors appeared in either log.
- Start-up failures show a clear message: port already in use, `PULSE_PORT` not a number, unwritable database path.
- The poll page's script, under Node with a minimal stand-in for the page, against the real server: loading the poll, voting, no choice selected, a rejected option, the server being down and a reply that is not JSON all showed the expected messages.
- Terraform MCP lookups through this session's Terraform MCP tools: 7 calls on 2026-11-21 (`get_latest_provider_version`, and `search_provider_docs` plus `get_provider_details` for `docker_image`, `docker_network` and `docker_container`), after the earlier `docker_volume` lookup. The server version behind them was not checked.
- Steps 2 and 4 of this document, run once by the assistant, as the worked example above.

**Not run:**

- Step 3 as a real human decision. The review gate was not approved by anyone.
- The prompts in a separate, fresh Claude Code session, and how different runs or attendees' runs differ.
- Any Terraform for this app. No infrastructure was created, planned or applied.
- The container finding (a 127.0.0.1 bind is not reachable through a published port): standard Docker behaviour, but nothing was containerised here.
- The poll page in a real browser (layout, dark mode, clicking).
- Python versions other than 3.15.2.
- GitHub Copilot and Codex. The MCP setup above is the Claude Code one.
