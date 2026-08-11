# Terraform v1.15 – Release Notes

> **Latest version: 1.15.8** (released 2026-07-08)

## v1.15.8 (2026-07-08)

## 1.15.8 (July 8, 2026)


BUG FIXES:

* Fix `terraform init` error when installing providers sourced from a service-discovery alias advertised by the configured backend (such as `localterraform.com`)


NOTES:

* command/init: Provider installation was changed to enable future enhancements in the area. This effectively reverses the log message changes from v1.15. `initializing_provider_plugin_message` is being re-introduced to replace the short-lived two message types `initializing_provider_plugin_from_config_message` & `initializing_provider_plugin_from_state_message`. The change should not have any significant end-user impact aside from the command output. ([#38838](https://github.com/hashicorp/terraform/issues/38838))

* command/init: Provider installation was changed to enable future enhancements in the area. This partially reverses the init event order changes from v1.15; module installation will now occur after the backend is initialized. The change should not have any significant end-user impact aside from the command output. ([#38838](https://github.com/hashicorp/terraform/issues/38838))

## v1.15.7 (2026-06-24)

## 1.15.7 (June 24, 2026)


BUG FIXES:

* Add concurrency safety to configs.Parser and SourceBundleParser ([#38745](https://github.com/hashicorp/terraform/issues/38745))

* Fix submodule variable validation during init ([#38770](https://github.com/hashicorp/terraform/issues/38770))

