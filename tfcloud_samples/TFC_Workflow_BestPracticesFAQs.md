# Best Practices to handle production and non-production Terraform automation using GitHub Actions workflows

To handle production and non-production Terraform automation using GitHub Actions workflows efficiently and securely, we can adopt a strategy that incorporates environment-specific configurations, manual approvals for production, and automated flows for non-production. Here's a step-by-step strategy:

1. Environment Configuration

- Use GitHub Environments: Define GitHub environments for production and non-production. Each environment can have its own set of secrets and protection rules.
- Environment-specific Secrets: Store environment-specific secrets (e.g., TF_API_TOKEN, AWS credentials) in GitHub Secrets at the environment level.

2. Workflow Structure

- Split our workflow into reusable parts using jobs and workflow_call events, allowing for code reuse across different environments and scenarios.

3. Terraform Workspaces

- Utilize Terraform workspaces to manage state files separately for each environment. This isolates state and makes it easier to manage changes across environments.

4. Manual Approvals for Production

- Manual Trigger for Production: Use the workflow_dispatch event or manual approvals in GitHub environments for production deployments. This ensures that changes are reviewed before being applied.
- Automated Flows for Non-Production: Allow automated execution for non-production environments to speed up development cycles.

5. Environment-specific Workflow Runs

- Conditional Steps: Use conditions in steps or jobs to differentiate between production and non-production actions. For example, use `if: github.ref == 'refs/heads/main' && github.event_name == 'workflow_dispatch'` for production-specific steps.
- Separate Workflows or Jobs: Consider having separate workflows or jobs for production and non-production, especially if the processes differ significantly.

```yaml
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

- Integrate IaC Scanning: Use tools like tfsec, checkov, or terrascan in our workflow to automatically scan Terraform code for best practices and security vulnerabilities.

## Branch naming suggestions

For managing production and non-production environments in a Git workflow, it's crucial to have a clear and consistent naming convention for branches. Here are some recommended branch names:

### Production

- **`main` or `master`**: Traditionally, the `main` (or `master`) branch represents the stable production code. All code that is deployed to the production environment should be merged into this branch.

### Non-Production

For non-production environments, wecan use a combination of branch names that reflect the environment and the purpose of the changes. Here are some suggestions:

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

By following these conventions, wecan maintain a clear and efficient workflow for managing production and non-production code, making it easier for team members to understand the purpose of each branch at a glance.

---

## Conclusion

This strategy ensures that our Terraform automation for production and non-production environments is secure, efficient, and follows best practices. It leverages GitHub's built-in features for environment management, manual approvals, and secret handling, alongside Terraform's capabilities for workspace and state management.

---

# Terraform GitHub Actions Best Practice FAQs

## Q : How to configure backend in tfc workspace for different environments?

To configure the backend for a Terraform Cloud (TFC) workspace, you typically use the Terraform configuration files to specify the backend details. Terraform Cloud acts as the backend, and you need to configure your Terraform files to use the `remote` backend, pointing to your TFC workspace. Here's how you can do it step-by-step:

### Step 1: Define the Terraform Backend

In your Terraform configuration (`main.tf` or another `.tf` file), define the `backend` block to use Terraform Cloud. You'll specify the organization name and the workspace name. Replace `your_organization` and `your_workspace` with your actual Terraform Cloud organization and workspace names.

```hcl
terraform {
  backend "remote" {
    organization = "your_organization"

    workspaces {
      name = "your_workspace"
    }
  }
}
```

### Step 2: Initialize Terraform

Run `terraform init` to initialize the Terraform configuration. This command will set up the Terraform Cloud backend, among other things. Make sure you have Terraform CLI installed and you are logged into Terraform Cloud via the CLI.

```bash
terraform init
```

### Step 3: Authenticate with Terraform Cloud

Ensure you're authenticated with Terraform Cloud. If you're using the Terraform CLI, you can log in to Terraform Cloud using the following command:

```bash
terraform login
```

This command generates a token and stores it locally, allowing Terraform commands to interact with your Terraform Cloud workspace.

### Step 4: Configure Workspace Variables in Terraform Cloud

Terraform Cloud workspaces support setting variables that can be used within your Terraform configuration. You can set these variables in the TFC UI under your workspace settings:

- **Terraform Variables**: Used for variables within your Terraform configuration.
- **Environment Variables**: Used for setting environment variables that Terraform or provider plugins will use.

### Step 5: Plan and Apply

With the backend configured, you can now use Terraform as usual to plan and apply your configurations. Terraform Cloud will automatically store your state and run plans and applies according to the settings in your workspace.

```bash
terraform plan
terraform apply
```

### Additional Tips

- **Workspaces for Different Environments**: Consider using separate workspaces for different environments (e.g., production, staging). This approach isolates state and variables for each environment.
- **Version Control Integration**: Terraform Cloud can integrate with your VCS (e.g., GitHub, GitLab). This allows for automatic triggering of Terraform plans and applies based on code changes.
- **Review Terraform Cloud Documentation**: Terraform Cloud offers many features like remote operations, team access controls, and more. Review the [official documentation](https://www.terraform.io/cloud-docs) for detailed guidance on leveraging these features.

By following these steps, you can configure and use a Terraform Cloud workspace as the backend for your Terraform configurations, leveraging TFC's capabilities for state management, collaboration, and automation.

## Q: how do I change the backend if I am running this GitHub Actions workflow for non-prod versus prod?

To change the Terraform backend configuration based on whether you are running a GitHub Actions workflow for a non-production or production environment, you can use environment variables and conditional logic within your workflow. This approach allows you to dynamically set backend configurations based on the context of the workflow run.

Here's a step-by-step guide on how to achieve this:

### 1. **Define Environment Variables**

Use GitHub Actions secrets to store environment-specific backend configurations. For example, you might have `TF_BACKEND_CONFIG_NONPROD` and `TF_BACKEND_CONFIG_PROD` as secrets containing the backend configuration details for non-production and production environments, respectively.

### 2. **Modify the Workflow to Use Conditional Logic**

In your workflow, use conditional logic to set the backend configuration based on the trigger or inputs to the workflow. You can use the `workflow_dispatch` event to manually trigger workflows and include an input that specifies the environment.

### 3. **Use a Script to Configure the Backend**

Before running Terraform commands, use a script step to dynamically generate the backend configuration file based on the specified environment.

Here's an example GitHub Actions workflow that demonstrates this approach:

```yaml
name: Terraform Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment (prod or nonprod)'
        required: true
        default: 'nonprod'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1

    - name: Configure Backend
      run: |
        if [ "${{ github.event.inputs.environment }}" = "prod" ]; then
          echo "${{ secrets.TF_BACKEND_CONFIG_PROD }}" > backend.tfvars
        else
          echo "${{ secrets.TF_BACKEND_CONFIG_NONPROD }}" > backend.tfvars
        fi

    - name: Terraform Init
      run: terraform init -backend-config=backend.tfvars

    - name: Terraform Apply
      run: terraform apply -auto-approve
```

In this example:

- The workflow is manually triggered with an `environment` input to specify the target environment (`prod` or `nonprod`).
- The "Configure Backend" step dynamically creates a `backend.tfvars` file with the backend configuration based on the specified environment. This configuration is pulled from the GitHub Actions secrets.
- Terraform commands use the generated `backend.tfvars` for initializing and applying configurations.

**Important**: Ensure that your backend configurations stored in GitHub Secrets are secure and have limited access. This approach allows you to maintain different backend configurations for different environments without hardcoding sensitive information in your workflow files.

## Q : How to use workflow dispatch on specific branch

To use the `workflow_dispatch` event to trigger a GitHub Actions workflow on a specific branch, you specify the branch or branches you want the workflow to run on under the `jobs.<job_id>.runs-on` field for job execution environment, and use the `ref` input under `workflow_dispatch` to specify the branch you want to trigger the workflow on. However, it's important to note that the `workflow_dispatch` event itself does not restrict which branch the workflow is triggered on; instead, it allows you to manually trigger the workflow from GitHub's UI or via the GitHub API. The branch restriction is applied at the job level within the workflow.

Here's how you can set up a workflow with `workflow_dispatch` that is intended to run on a specific branch when manually triggered:

```yaml
name: Manual Workflow Dispatch Example

on:
  workflow_dispatch:
    inputs:
      target_branch:
        description: 'Branch to run the workflow on'
        required: true
        default: 'main' # Default branch

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        ref: ${{ github.event.inputs.target_branch }}
    - name: Run a script
      run: |
        echo "Workflow running on branch ${{ github.event.inputs.target_branch }}"
```

In this example, when you trigger the workflow manually, you can specify the branch you want to run the workflow on by setting the `target_branch` input. The workflow will check out the repository at the specified branch using the `actions/checkout@v2` action with the `ref` input set to the branch name provided by the user.

This approach provides flexibility in specifying the branch at the time of triggering the workflow. Remember, the actual execution of jobs and steps is not restricted by the branch unless you explicitly configure it to be so, as shown in the example.

## Q : What is the best practice for running terraform using "on" keyword. Which branch needs to be triggered automatically, and which branch needs manual trigger

When using Terraform in a CI/CD pipeline with GitHub Actions, best practices for triggering workflows with the `on` keyword depend on your development workflow, branching strategy, and how you manage your infrastructure changes. Here's a general approach that aligns with common practices:

### Main or Production Branch (Automated Trigger)

- **Branch**: Typically, `main` or `production`.

- **Trigger**: Automated triggers are used for this branch to apply changes to production infrastructure or a staging environment that mirrors production closely. This ensures that changes are automatically deployed once they are fully tested and merged into the main branch.

- **Workflow Event**: `push` or `pull_request` for continuous integration, ensuring that changes are tested before they are merged.

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

### Development or Feature Branches (Manual Trigger)

- **Branch**: Development, feature, or any non-production branches.

- **Trigger**: Manual triggers are useful here to allow developers or operations teams to plan and apply Terraform changes in a controlled manner, ensuring that changes can be reviewed and applied when necessary without automatically affecting live infrastructure.

- **Workflow Event**: `workflow_dispatch` allows for manual execution, providing flexibility to run Terraform plans and applies on demand.

```yaml
on:
  workflow_dispatch:
    branches:
      - develop
      - feature/**
```

### Combining Both Approaches

In practice, you might combine both automated and manual triggers in your GitHub Actions workflow to accommodate different stages of your development and deployment pipeline.

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:
    branches:
      - develop
      - feature/**
```

### Best Practices Summary

- **Automate Testing and Deployment to Main/Production**: Automate as much of the testing and deployment process as possible for your main or production branch to streamline your workflow and reduce human error.

- **Use Manual Triggers for Development and Features**: Utilize manual triggers for development and feature branches to provide control over when and how changes are applied, allowing for detailed review and planning.

- **Branch Protection Rules**: Implement branch protection rules for your main or production branch to require pull request reviews, status checks, and more before merging.

- **Terraform State Management**: Ensure your Terraform state is securely managed and backed up. Consider using Terraform Cloud or a similar service for state management, especially when working in a team environment.

- **Review and Approval Process**: Incorporate a review and approval process for infrastructure changes, especially for those affecting production environments.

Adapting these practices to fit your team's workflow and the specifics of your infrastructure will help maintain a balance between agility and stability in your infrastructure management process.

---

# How to package Terraform Code

To package Terraform code for deployment or distribution, wetypically want to bundle our Terraform configuration files (`*.tf`) along with any associated files (e.g., `*.tfvars`, scripts) into a single archive file. This can be useful for versioning, sharing configurations, or deploying through CI/CD pipelines. Here's a step-by-step guide on how to do this, assuming you're working in a Unix-like environment (e.g., Linux, macOS):

## Step 1: Organize our Terraform Configuration

Ensure our Terraform configuration files are organized and all necessary files are included in our project directory. This includes:

- Terraform configuration files (`*.tf`)
- Variable files (`*.tfvars`, if not using environment variables)
- Any scripts or additional files needed for our Terraform configurations

## Step 2: Write a Script to Package the Configuration

We can write a simple shell script to package our Terraform configuration. This script will:

1. Clean up any previous builds (optional).
2. Run `terraform init` and `terraform validate` to ensure our configuration is valid.
3. Create a ZIP archive of our Terraform configuration.

Here's an example script named `package_terraform.sh`:

```bash
#!/bin/bash

# Define variables
PROJECT_DIR="path/to/our/terraform/configuration"
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

## Step 3: Execute the Script

Make our script executable and run it:

```bash
chmod +x package_terraform.sh
./package_terraform.sh
```

This script will create a ZIP file containing all our Terraform configuration files. we can then use this ZIP file in our CI/CD pipeline, share it with our team, or keep it for versioning purposes.

## Notes

- Ensure we do not include any sensitive information (e.g., `terraform.tfstate`, `*.tfvars` with sensitive defaults) in the ZIP file. Use environment variables or CI/CD pipeline secrets to handle sensitive data.
- Adjust the `PROJECT_DIR` and `BUILD_DIR` variables in the script according to our project's directory structure.
- This example uses ZIP for packaging, but we can use other formats (e.g., tar) depending on our needs or environment.