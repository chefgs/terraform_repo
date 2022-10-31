## Download tf sdk migrator

$ go get github.com/hashicorp/tf-sdk-migrator
go: downloading github.com/hashicorp/tf-sdk-migrator v1.4.0
go: downloading github.com/kmoe/go-list v1.0.0
go: downloading github.com/radeksimko/go-refs v0.0.0-20190823125319-880a3294a1a0
go: downloading golang.org/x/mod v0.2.0
go: downloading golang.org/x/xerrors v0.0.0-20191011141410-1b5146add898
go: downloading golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550
go: added github.com/hashicorp/tf-sdk-migrator v1.4.0

$ go install github.com/hashicorp/tf-sdk-migrator

$ ~/go/bin/tf-sdk-migrator 
Usage: tf-sdk-migrator [--version] [--help] <command> [<args>]

Available commands are:
    check        Checks whether a Terraform provider is ready to be migrated to the new SDK (v1).
    migrate      Migrates a Terraform provider to the new SDK (v1).
    v2upgrade    Upgrades the Terraform provider SDK version to v2.

### Migrate tf v0.11 to tf0.12

$ ~/go/bin/tf-sdk-migrator check
Checking Go runtime version ...
Go version 1.18.2: OK.
Checking whether provider uses Go modules...
Go modules in use: OK.
Checking version of github.com/hashicorp/terraform-plugin-sdk to determine if provider was already migrated...
Provider already migrated to SDK version 1.14.0

$ ~/go/bin/tf-sdk-migrator migrate
Checking Go runtime version ...
Go version 1.18.2: OK.
Checking whether provider uses Go modules...
Go modules in use: OK.
Checking version of github.com/hashicorp/terraform-plugin-sdk to determine if provider was already migrated...
Provider already migrated to SDK version 1.14.0
Provider failed eligibility check for migration to the new SDK. Please see messages above.

$ ~/go/bin/tf-sdk-migrator v2upgrade
Rewriting provider go.mod file...
Rewriting SDK package imports...
Running `go mod tidy`...
Success! Provider is upgraded to github.com/hashicorp/terraform-plugin-sdk/v2 v2.4.3.
Failed to check vendor folder: stat $USER_HOME/go/src/tf_custom_provider_new/vendor: no such file or directory

## Since vendor command failed, we need to run manually
$ go mod vendor

## Refer
https://support.hashicorp.com/hc/en-us/articles/5511799316243-Error-Failed-to-query-available-provider-packages

https://github.com/hashicorp/terraform/issues/26532#issuecomment-887842128

https://www.terraform.io/language/providers/requirements#in-house-providers

https://www.terraform.io/cli/config/config-file#implied-local-mirror-directories

https://www.hashicorp.com/blog/writing-custom-terraform-providers

https://www.terraform.io/plugin/hashicorp-provider-design-principles

https://www.terraform.io/plugin/sdkv2/guides/v1-upgrade-guide#how-do-i-migrate-my-provider-to-the-standalone-sdk
