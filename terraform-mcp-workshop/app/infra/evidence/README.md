# Evidence for the poll's Docker deployment (2026-11-21)

Outputs from the run that created the poll in a local Docker container, and from the destroy that removed it afterwards. They show what was run and what came back. They are not a test suite, and they are **not exhaustive**: some checks were run in the session and never saved to a file. `run-log.txt` lists them in its header. The main one is the pre-apply state (engine reachable, port 8000 free, no existing container or volume). It was observed on screen only and cannot be recaptured.

| File | What it is |
|---|---|
| `run-log.txt` | Chronological output of `init`, `plan`, `validate`, `apply`, the read-only post-apply checks and a no-change plan. |
| `plan.txt` | The saved plan that was applied, rendered with `terraform show -no-color`. |
| `mcp-lookups.md` | The Terraform MCP registry calls, the documentation IDs returned and the arguments verified. |
| `destroy-log.txt` | The cleanup: the state and the vote count before it, `plan -destroy`, `apply` of the saved destroy plan, and read-only checks that everything was removed. |

## How they were made

- By the assistant in one Claude Code session, with Terraform 1.17.2, `kreuzwerker/docker` 4.6.0 and Docker Desktop's local engine, each step at the owner's explicit instruction. `DOCKER_HOST` was set inline to the local socket after the context was checked.
- Sanitised: the workshop folder appears as `<workshop>` and the local Docker socket path is removed.
- Container and image IDs are kept. They are specific to that machine and are not secrets.

## Deliberately not included

| Not included | Why |
|---|---|
| `terraform.tfstate` | The lab rules say not to share state. It also records the live resources. |
| `poll.tfplan`, `cleanup.tfplan` and `plan.json` | The lab checklist says to exclude binary plans and plan JSON. They also hold full local paths. |

All of these are git-ignored.
