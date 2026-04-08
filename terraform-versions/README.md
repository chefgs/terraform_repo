# Terraform Version History – IaC Reference Guide

Quick reference for major Terraform versions from v1.0+ with key features, syntax changes, and code examples.

> **Latest stable release:** [**v1.14.8**](./v1.14/) — 2026-03-25

## Version Timeline

| Version | Release | Key Feature |
|---------|---------|-------------|
| [v1.0](./v1.0/) | Jun 2021 | Stable API, backward compatibility guarantee |
| [v1.1](./v1.1/) | Dec 2021 | `moved` block, `cloud` block (TFC backend) |
| [v1.2](./v1.2/) | May 2022 | Preconditions/postconditions, `replace_triggered_by` |
| [v1.3](./v1.3/) | Sep 2022 | Optional object attributes, `import` improvements |
| [v1.4](./v1.4/) | Mar 2023 | `import` block, improved error messages |
| [v1.5](./v1.5/) | Jun 2023 | `import` block GA, `check` block, `inject_header` |
| [v1.6](./v1.6/) | Oct 2023 | `terraform test` GA, OPA/Sentinel, S3 backend improvements |
| [v1.7](./v1.7/) | Jan 2024 | `mock_provider` for tests, `removed` block |
| [v1.8](./v1.8/) | Apr 2024 | Provider-defined functions, stacks preview |
| [v1.9](./v1.9/) | Jun 2024 | Variable validation across modules, `templatestring` function |
| [v1.10](./v1.10/) | Nov 2024 | Ephemeral resources (experimental), `write_only` attributes |
| [v1.11](./v1.11/) | Feb 2025 | Ephemeral resources GA, `provider for_each` (experimental) |
| [v1.12](./v1.12/) | May 2025 | `provider for_each` GA, Stacks enhancements |
| [v1.13](./v1.13/) | Sep 2025 | Enhanced module iteration, `strcontains`/`strtitle` functions |
| [**v1.14.7**](./v1.14/) | **Mar 11, 2026** | Deferred changes GA, test setup/teardown, auto lock file platforms |

## How to Use

Each version directory contains:
- `CHANGELOG.md` – What changed in this version
- `examples/` – Working code examples of new features
- `upgrade-guide.md` – How to upgrade from the previous version

## Upgrade Strategy

```bash
# Check current version
terraform version

# Install latest stable version using tfenv
tfenv install 1.14.7
tfenv use 1.14.7

# Or using asdf
asdf install terraform 1.14.7
asdf global terraform 1.14.7

# Install a specific older version
tfenv install 1.9.0
tfenv use 1.9.0
```
