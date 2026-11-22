# Terraform MCP registry lookups for app/infra (2026-11-21)

These are the registry tool calls made in the session that wrote `app/infra/main.tf`, with what each returned. They are tools of the Terraform MCP server (registry toolset). None of them ran Terraform: the Terraform CLI was run separately in the terminal (see `run-log.txt`).

Provider: `kreuzwerker/docker`. Documentation version used: **4.6.0** (the workshop pin).

| # | Tool | Input | Returned |
|---|---|---|---|
| 1 | `get_latest_provider_version` | `kreuzwerker/docker` | `4.7.0` (newer than the 4.6.0 pin) |
| 2 | `search_provider_docs` | `container`, resources, v4.6.0 | `providerDocID 13459279` (container) |
| 3 | `search_provider_docs` | `image`, resources, v4.6.0 | `13459280` (image). `13459283` (registry_image) also matched and was not used. |
| 4 | `search_provider_docs` | `volume`, resources, v4.6.0 | `13459287` (volume) |
| 5 | `search_provider_docs` | `network`, resources, v4.6.0 | `13459281` (network) |
| 6 | `get_provider_details` | `13459279` | `docker_container` documentation |
| 7 | `get_provider_details` | `13459280` | `docker_image` documentation |
| 8 | `get_provider_details` | `13459287` | `docker_volume` documentation |
| 9 | `get_provider_details` | `13459281` | `docker_network` documentation |

All four resources were documented at 4.6.0. `get_provider_capabilities` was not called. The 4.7.0 documentation was not retrieved.

## Arguments used in `main.tf` and where they were verified

| Resource | Arguments used | Verified in doc |
|---|---|---|
| `docker_container` | `name`, `image`, `command`, `env`, `ports` (`internal`, `external`, `ip`), `volumes` (`host_path`, `volume_name`, `container_path`, `read_only`), `healthcheck` (`test`, `interval`, `timeout`, `retries`, `start_period`) | 13459279 |
| `docker_image` | `name`, `keep_locally`, read-only `image_id` | 13459280 |
| `docker_volume` | `name` | 13459287 |

Points taken from the documentation that shaped the code:

- `ports.ip` defaults to `0.0.0.0`, so `main.tf` sets `127.0.0.1` explicitly.
- The `healthcheck` durations default to `0s`, so they are set explicitly.
- `docker_volume.name` is generated if omitted, so it is set explicitly.
- `docker_network` is documented but not used: the approved architecture has no network.

## Not verified by these tools

- `abspath`, `path.module` and the `host_port` variable validation are Terraform language, not provider documentation. They were checked by `terraform validate` (see `run-log.txt`).
- That the image `python:3.15-alpine` exists. The registry tools check provider documentation only, not Docker Hub. It was confirmed later only because the apply pulled it.
- That the app listens on `0.0.0.0` in the container and answers through the loopback-only published port. This came from the app's own documentation and was confirmed only by the apply and the post-apply checks.
