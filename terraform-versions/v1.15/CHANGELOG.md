# Terraform v1.15 – Release Notes

> **Latest version: 1.15.3** (released 2026-05-13)

## v1.15.3 (2026-05-13)

## 1.15.3 (May 13, 2026)


BUG FIXES:

* stacks: Fixed a bug that prevented migrating resources under multiple layers of module nesting with implicit provider configuration. ([#38528](https://github.com/hashicorp/terraform/issues/38528))

* cloud backend will now forward -generate-config-out flag usage to query create request ([#38539](https://github.com/hashicorp/terraform/issues/38539))

* Fix crash during provider installation when there is no config ([#38560](https://github.com/hashicorp/terraform/issues/38560))
