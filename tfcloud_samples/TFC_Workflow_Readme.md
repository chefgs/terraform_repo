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

## Conclusion
This strategy ensures that your Terraform automation for production and non-production environments is secure, efficient, and follows best practices. It leverages GitHub's built-in features for environment management, manual approvals, and secret handling, alongside Terraform's capabilities for workspace and state management.