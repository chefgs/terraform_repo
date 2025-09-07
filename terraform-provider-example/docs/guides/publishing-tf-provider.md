# Publishing a Terraform Provider on GitHub

**Table of Contents:**

- [Prerequisites](#prerequisites)
- [Step 1: Prepare Your Repository](#step-1-prepare-your-repository)
- [Step 2: Set Up Release Automation](#step-2-set-up-release-automation)
- [Step 3: Update Your Provider for Distribution](#step-3-update-your-provider-for-distribution)
- [Step 4: Create a Release](#step-4-create-a-release)
- [Step 5: Prepare Installation Instructions for Users](#step-5-prepare-installation-instructions-for-users)
- [Step 6: (Optional) Publishing to the Terraform Registry](#step-6-optional-publishing-to-the-terraform-registry)
- [Testing Your Release](#testing-your-release)
- [Maintaining Your Provider](#maintaining-your-provider)

Here's a step-by-step guide to publish your custom Terraform provider on your personal GitHub account, making it easy for users to download and use.

## Prerequisites

- A GitHub account
- Git installed on your local machine
- Your Terraform provider code ready for distribution
- Go installed (for building the provider)

## Step 1: Prepare Your Repository

1. Create a new GitHub repository with a descriptive name:
   - Name format: `terraform-provider-{name}` (e.g., terraform-provider-example)
   - Make it public so others can access it

2. Initialize your local repository (if not already done):

   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/terraform-provider-example.git
   git push -u origin main
   ```

## Step 2: Set Up Release Automation

1. Create a `.github/workflows/release.yml` file in your repository:

   ```yaml
   name: Release

   on:
     push:
       tags:
         - 'v*'

   permissions:
     contents: write

   jobs:
     goreleaser:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout
           uses: actions/checkout@v3
           with:
             fetch-depth: 0

         - name: Set up Go
           uses: actions/setup-go@v4
           with:
             go-version: '1.21'

         - name: Run GoReleaser
           uses: goreleaser/goreleaser-action@v4
           with:
             version: latest
             args: release --clean
           env:
             GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```

2. Create a `.goreleaser.yml` file in the root of your repository:

   ```yaml
   before:
     hooks:
       - go mod tidy

   builds:
     - env:
         - CGO_ENABLED=0
       mod_timestamp: '{{ .CommitTimestamp }}'
       flags:
         - -trimpath
       ldflags:
         - '-s -w -X main.version={{.Version}}'
       goos:
         - windows
         - linux
         - darwin
       goarch:
         - amd64
         - arm64
       ignore:
         - goos: windows
           goarch: arm64

   archives:
     - format: zip
       name_template: '{{ .ProjectName }}_{{ .Version }}_{{ .Os }}_{{ .Arch }}'

   checksum:
     name_template: '{{ .ProjectName }}_{{ .Version }}_SHA256SUMS'
     algorithm: sha256

   release:
     draft: false

   changelog:
     skip: false
     sort: asc
     filters:
       exclude:
         - '^docs:'
         - '^test:'
         - '^ci:'
   ```

3. Commit these workflow files:

   ```bash
   git add .github/workflows/release.yml .goreleaser.yml
   git commit -m "Add release workflow"
   git push
   ```

## Step 3: Update Your Provider for Distribution

1. Ensure your `main.go` file has a version variable that can be set during build:

   ```go
   var (
     // This will be set by the goreleaser configuration
     // to appropriate values for the compiled binary
     version string = "dev"
   )
   ```

2. Make sure your provider address in `main.go` matches your GitHub username:

   ```go
   opts := providerserver.ServeOpts{
     Address: "registry.terraform.io/yourusername/example",
     Debug:   debug,
   }
   ```

3. Create comprehensive documentation in your repository:
   - README.md with installation and usage instructions
   - Example configurations
   - Provider and resource documentation

## Step 4: Create a Release

1. Tag a new version following semantic versioning:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. This will trigger the GitHub Actions workflow you set up, which will:
   - Build your provider for multiple platforms
   - Create ZIP archives of the binaries
   - Generate checksums
   - Create a GitHub release with these assets

3. Once the workflow completes, you'll see a new release on your GitHub repository with all the binary files attached.

## Step 5: Prepare Installation Instructions for Users

Create a section in your README.md with clear installation instructions:

```markdown
## Installation

### Automatic Installation (Terraform 0.13+)

You can use the provider from this repository by adding the following to your Terraform configuration:

```hcl
terraform {
  required_providers {
    example = {
      source  = "yourusername/example"
      version = "1.0.0"
    }
  }
}
```

### Manual Installation

If you prefer to install the provider manually:

1. Download the latest release for your platform from [GitHub Releases](https://github.com/yourusername/terraform-provider-example/releases)
2. Extract the ZIP file
3. Move the binary to the Terraform plugin directory:

```bash
mkdir -p ~/.terraform.d/plugins/registry.terraform.io/yourusername/example/1.0.0/$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/')
mv terraform-provider-example_v1.0.0 ~/.terraform.d/plugins/registry.terraform.io/yourusername/example/1.0.0/$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/')/terraform-provider-example
chmod +x ~/.terraform.d/plugins/registry.terraform.io/yourusername/example/1.0.0/$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/')/terraform-provider-example
```

## Step 6: (Optional) Publishing to the Terraform Registry

If you want to make it even easier for users, you can publish to the Terraform Registry:

1. Ensure your GitHub repository is public
2. Sign in to the [Terraform Registry](https://registry.terraform.io/)
3. Follow the "Publish" workflow, which will ask you to select your GitHub repository
4. The Registry will verify your repository meets requirements and then publish it

## Testing Your Release

Before announcing your provider, test the installation process yourself:

1. Download the release ZIP for your platform
2. Follow your own installation instructions
3. Create a test Terraform configuration that uses your provider
4. Run `terraform init` and verify it can find and install your provider
5. Test a full `terraform apply` cycle to ensure everything works

## Maintaining Your Provider

1. Address issues and feature requests from users
2. Make regular releases with bug fixes and improvements
3. Keep documentation up to date
4. Clearly communicate breaking changes
5. Follow semantic versioning for releases

By following these steps, you'll have a well-organized, professionally distributed Terraform provider that users can easily install and use from your GitHub repository.

