# How to handle production and non-production Terraform automation using GitHub Actions workflows
To handle production and non-production Terraform automation using GitHub Actions workflows efficiently and securely, we can adopt a strategy that incorporates environment-specific configurations, manual approvals for production, and automated flows for non-production. Here's a step-by-step strategy:

## Best Practices

1. Environment Configuration
  - Use GitHub Environments: Define GitHub environments for production and non-production. Each environment can have its own set of secrets and protection rules.
  - Environment-specific Secrets: Store environment-specific secrets (e.g., TF_API_TOKEN, AWS credentials) in GitHub Secrets at the environment level.

2. Workflow Structure
  - Split your workflow into reusable parts using jobs and workflow_call events, allowing for code reuse across different environments and scenarios.

3. Terraform Workspaces
  - Utilize Terraform workspaces to manage state files separately for each environment. This isolates state and makes it easier to manage changes across environments.

4. Manual Approvals for Production
  - Manual Trigger for Production: Use the workflow_dispatch event or manual approvals in GitHub environments for production deployments. This ensures that changes are reviewed before being applied.
  - Automated Flows for Non-Production: Allow automated execution for non-production environments to speed up development cycles.

5. Environment-specific Workflow Runs
  - Conditional Steps: Use conditions in steps or jobs to differentiate between production and non-production actions. For example, use `if: github.ref == 'refs/heads/main' && github.event_name == 'workflow_dispatch'` for production-specific steps.
  - Separate Workflows or Jobs: Consider having separate workflows or jobs for production and non-production, especially if the processes differ significantly.

```
environments:
  production:
	protection_rules:
	  required_reviewers:
		- username1
		- username2

jobs:
  plan:
	runs-on: ubuntu-latest
	steps:
	  - name: Terraform Plan
		run: terraform plan -out=tfplan
		# Add other steps as necessary

  apply:
	needs: plan
	if: github.event_name == 'workflow_dispatch'
	runs-on: ubuntu-latest
	environment: production
	steps:
	  - name: Terraform Apply
		run: terraform apply tfplan
		# Add other steps as necessary
```

6. Code Review and Pull Requests
  - Pull Request Reviews: Require pull request reviews for changes to Terraform files, ensuring that changes are vetted before being merged into the main branch.
  - Branch Protection Rules: Implement branch protection rules for the main branch to prevent direct pushes and ensure that changes go through a pull request.

7. Infrastructure as Code (IaC) Scanning
  - Integrate IaC Scanning: Use tools like tfsec, checkov, or terrascan in your workflow to automatically scan Terraform code for best practices and security vulnerabilities.

8. Branch naming suggestions

For managing production and non-production environments in a Git workflow, it's crucial to have a clear and consistent naming convention for branches. Here are some recommended branch names:

### Production
- **`main` or `master`**: Traditionally, the `main` (or `master`) branch represents the stable production code. All code that is deployed to the production environment should be merged into this branch.

### Non-Production
For non-production environments, you can use a combination of branch names that reflect the environment and the purpose of the changes. Here are some suggestions:

- **`develop` or `development`**: This branch serves as an integration branch for features. It's where developers merge their feature branches before the code is released to a staging environment.
- **`feature/feature-name`**: Feature branches are used by developers to work on new features or changes. Each feature branch is named after the feature or task (e.g., `feature/add-login`).
- **`bugfix/bug-name`**: Bugfix branches are used to work on fixing bugs. They are named after the bug or issue they aim to fix (e.g., `bugfix/login-error`).
- **`hotfix/hotfix-name`**: Hotfix branches are used for making critical fixes that need to be deployed to production outside of the regular release cycle (e.g., `hotfix/security-patch`).
- **`release/version`**: Release branches are used to prepare for a new production release. They allow for last-minute dotting of i's and crossing of t's. They are named after the version of the release (e.g., `release/1.0.0`).
- **`staging` or `qa`**: These branches can be used as pre-production branches where final testing is performed before merging into `main`. They represent the staging or QA environment.

### Branch Naming Tips
- **Consistency**: Stick to a naming convention that is understood by all team members.
- **Clarity**: The branch name should make it clear what is contained in the branch.
- **Brevity**: Keep branch names short but descriptive.

By following these conventions, you can maintain a clear and efficient workflow for managing production and non-production code, making it easier for team members to understand the purpose of each branch at a glance.

---

## Conclusion
This strategy ensures that your Terraform automation for production and non-production environments is secure, efficient, and follows best practices. It leverages GitHub's built-in features for environment management, manual approvals, and secret handling, alongside Terraform's capabilities for workspace and state management.

---

# How to package Terraform Code

To package Terraform code for deployment or distribution, you typically want to bundle your Terraform configuration files (`*.tf`) along with any associated files (e.g., `*.tfvars`, scripts) into a single archive file. This can be useful for versioning, sharing configurations, or deploying through CI/CD pipelines. Here's a step-by-step guide on how to do this, assuming you're working in a Unix-like environment (e.g., Linux, macOS):

### Step 1: Organize Your Terraform Configuration
Ensure your Terraform configuration files are organized and all necessary files are included in your project directory. This includes:
- Terraform configuration files (`*.tf`)
- Variable files (`*.tfvars`, if not using environment variables)
- Any scripts or additional files needed for your Terraform configurations

### Step 2: Write a Script to Package the Configuration
You can write a simple shell script to package your Terraform configuration. This script will:
1. Clean up any previous builds (optional).
2. Run `terraform init` and `terraform validate` to ensure your configuration is valid.
3. Create a ZIP archive of your Terraform configuration.

Here's an example script named `package_terraform.sh`:

```bash
#!/bin/bash

# Define variables
PROJECT_DIR="path/to/your/terraform/configuration"
BUILD_DIR="build"
ARCHIVE_NAME="terraform_config.zip"

# Step 1: Clean up previous builds
echo "Cleaning up previous builds..."
rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

# Step 2: Initialize and validate Terraform configuration
echo "Initializing and validating Terraform configuration..."
cd "$PROJECT_DIR" || exit
terraform init
terraform validate

# Step 3: Package Terraform configuration
echo "Packaging Terraform configuration..."
zip -r "../$BUILD_DIR/$ARCHIVE_NAME" ./*

echo "Terraform configuration package is ready: $BUILD_DIR/$ARCHIVE_NAME"
```

### Step 3: Execute the Script
Make your script executable and run it:

```bash
chmod +x package_terraform.sh
./package_terraform.sh
```

This script will create a ZIP file containing all your Terraform configuration files. You can then use this ZIP file in your CI/CD pipeline, share it with your team, or keep it for versioning purposes.

### Notes:
- Ensure you do not include any sensitive information (e.g., `terraform.tfstate`, `*.tfvars` with sensitive defaults) in the ZIP file. Use environment variables or CI/CD pipeline secrets to handle sensitive data.
- Adjust the `PROJECT_DIR` and `BUILD_DIR` variables in the script according to your project's directory structure.
- This example uses ZIP for packaging, but you can use other formats (e.g., tar) depending on your needs or environment.