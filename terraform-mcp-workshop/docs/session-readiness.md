# Session readiness

Checklist for the Terraform MCP workshop. Tick items as you complete them.

- `[ ]` = action item for you
- **Notice** = something to tell attendees during the session. The slide pointer shows where, in [session-slides.md](session-slides.md).

Last updated: 2026-11-19 (after review decisions on wording, README path, handout files and timings). Status words to use in the notes column: **not run**, **passed**, **failed**, **blocked**.

## What was verified, and what was not

| Item | Status | Source |
|---|---|---|
| `kreuzwerker/docker` 4.6.0 exists and its `docker_container` docs can be retrieved | Passed, 2026-11-19 | Terraform MCP server, in the authoring session |
| Latest `kreuzwerker/docker` version is 4.7.0 | Passed, 2026-11-19 | Terraform MCP server |
| HashiCorp deploy options (Local, Self-hosted, Remote) | Read once, 2026-11-19 | HashiCorp deploy pages |
| Lab run end to end (init, validate, plan, apply, change, destroy) | **Not run** | |
| `nginx:1.28-alpine` and MCP image `1.4.1` pull | **Not run** | |
| Claude Code connects using `.mcp.json` from the repo subfolder | **Not run** | |
| Mermaid diagrams render on GitHub | **Not run** | |
| Copilot and Codex setup steps | **Not run**. They are in the Process Guide only. | |
| Process Guide `.docx` after script edits | Zip check and text check passed. **Not opened** in a word processor. | |

## A. Action items before the session

### Must do

- [ ] **A1. Run the lab end to end yourself.** From `terraform-mcp-workshop/`: `init`, `fmt`, `validate`, `plan`, then optionally `apply`, the port change and `destroy`. Record the result in the rehearsal record below.
- [ ] **A2. Check the images pull.** `docker pull hashicorp/terraform-mcp-server:1.4.1` and `docker pull nginx:1.28-alpine`.
- [ ] **A3. Confirm the MCP connection in your client.** Launch from the `terraform-mcp-workshop/` folder, approve the project MCP prompt, run `/mcp`, and check that `terraform` is connected. The server dropped from the authoring session after a reconnect, so know how to reconnect with `/mcp`.
- [ ] **A4. Do a real lookup in your client** with the slide 13 prompt and confirm visible tool calls.
- [ ] **A5. Preview the Mermaid diagrams** on the GitHub branch view for `session-intro.md` and `session-slides.md`.
- [ ] **A6. Check the tool names on slide 8** against what your client lists. They came from the connected server in the authoring session, not from HashiCorp's Reference page.

### Re-check facts that may change

- [ ] **A7. Re-read HashiCorp's deploy pages**, especially the remote server: beta, US HCP Terraform organisations only, rate limits.
  - https://developer.hashicorp.com/terraform/mcp-server/deploy
  - https://developer.hashicorp.com/terraform/mcp-server/deploy/remote-mcp
- [ ] **A8. Re-check the provider version** if you changed the pin. Latest on 2026-11-19 was 4.7.0. The lab pins 4.6.0.
- [ ] **A9. Check the table cells that say "Not marked beta"** (slide 9). They mean the deploy page did not label them beta, not that they are officially generally available.

### Your decisions

- [x] **A10. Wording:** decided on "self-hosted". Slides and intro use "Self-hosted on your laptop" and note that HashiCorp's docs call this setup "Local".
- [x] **A11. README path:** updated to clone the repo and `cd terraform_repo/terraform-mcp-workshop`. The clone steps themselves have not been run (see A19).
- [x] **A12. Process Guide handout:** `Terraform_MCP_Process_Guide.md` and `.docx` are in `docs/`. The ChatGPT starter-kit link and `~/Downloads` paths were replaced with the repo clone steps. The identical `(1).docx` duplicate was not added.
- [x] **A13. Other AI tools:** the README and slide 12 point to the Process Guide for GitHub Copilot and Codex, marked untested.
- [x] **A14. Timings:** removed from the slides, README and Process Guide.
- [ ] **A15. Slides 17 and 19:** keep or cut the optional apply and the agentic app section, depending on your slot.
- [ ] **A19. Open `Terraform_MCP_Process_Guide.docx` in Word or Pages.** It was edited by script (links, paths, timing removed). The file passes a zip integrity check and its text reads correctly, but it has not been opened in a word processor.
- [ ] **A20. Test the clone steps** from the README on a clean folder: `git clone`, `git switch feature/mcp_workshop`, `cd terraform-mcp-workshop`. After the merge, drop the `git switch` line from the README and the guide.

### Logistics

- [ ] **A16. Tell attendees the prerequisites before the event:** Docker running, Terraform installed, internet access, and a login for their chosen AI tool.
- [ ] **A17. Merge** `feature/mcp_workshop` after the session. Fetch first. If `origin/main` has moved, rebase, and note that rebasing a pushed branch needs a force-push.
- [ ] **A18. Clean up after rehearsal:** no state, plan files or `terraform.tfvars` with personal values committed. The `.gitignore` already excludes state, plans and `plan.json`.

## B. Session notices (tell attendees)

| # | Notice | Slide |
|---|---|---|
| B1 | This runs on a laptop with Docker. No cloud account is needed. Internet and an AI tool login are required. | 1 |
| B2 | The manual vs AI comparison is qualitative. No timings are claimed. Manual still wins for learning a provider. | 5 |
| B3 | MCP helps while developing. It is not part of the running application. | 7 |
| B4 | Only the registry toolset is enabled: read-only docs lookup, no tokens, no changes to infrastructure. The full server has workspace and run tools that need a token and can change things. | 8 |
| B5 | We self-host the server in Docker on the laptop. HashiCorp's docs call that setup **Local** and use **Self-hosted** for a shared server a team operates over HTTP. | 9 |
| B6 | The remote server is beta, needs an HCP Terraform token, supports US HCP Terraform organisations only, and is rate limited. | 9 |
| B7 | The server does not work offline. Lookups are live calls to the registry, and the AI tool needs its model service. | 10 |
| B8 | Launch the AI tool from the terminal where `DOCKER_HOST` is set, so it uses the local Docker engine. | 11 |
| B9 | The image tag is pinned on purpose. | 12 |
| B10 | A confident answer with no tool call is not proof of a lookup. Ask the AI to show the tools it called. | 13 |
| B11 | The lab pins Docker provider 4.6.0 for repeatability. The latest version on 2026-11-19 was 4.7.0. | 13 |
| B12 | `validate` does not prove the plan or the runtime. | 15 |
| B13 | A plan does not prove the image will pull or the page will be healthy. You can stop after the plan. | 16 |
| B14 | Applying a saved plan has no yes/no prompt. Running it is your approval, so you run it, not the agent. | 17 |
| B15 | Never use `docker system prune` as cleanup. Do not delete Terraform state before destroying. | 17 |
| B16 | The agentic app section is an architecture discussion. The lab does not build it. | 19 |
| B17 | If you did not complete the rehearsal, say which parts are untested. | Opening |

## C. Rehearsal record

Date ____________  Client ____________  Client version ____________

| Step | Result | Notes |
|---|---|---|
| Terraform, Docker versions and context recorded | | |
| MCP connected (`/mcp`) | | |
| Real lookup showed tool calls | | |
| `init` | | |
| `fmt -check` | | |
| `validate` | | |
| `plan` (three creations expected) | | |
| `apply`, health check, no-change plan | | |
| Port change plan and apply | | |
| Destroy and cleanup verified | | |
| Mermaid diagrams render | | |

Known limitations or changes to share with attendees:

-
-
