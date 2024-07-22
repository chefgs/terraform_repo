## Details of Terraform Cloud & GitHub Action Workflow

Here is the details of each sections of the [workflow code](../.github/workflows/tf_cloud_aws.yml) 

### Workflow Header and Triggers

```yaml
# This workflow will create AWS resource using TF Cloud 
# It is reusable workflow that can be called in other workflows

name: AWS Infra Creation Using in TF Cloud 

on:
  workflow_call:
    secrets:
        TF_API_TOKEN:
            required: true
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:
```

- **name**: Defines the name of the workflow. Here, it is "AWS Infra Creation Using in TF Cloud".
- **on**: Specifies the events that trigger the workflow. This workflow can be triggered by:
  - **workflow_call**: This allows the workflow to be reused in other workflows. It requires the `TF_API_TOKEN` secret.
  - **push**: Triggers the workflow when there is a push to the "main" branch.
  - **pull_request**: Triggers the workflow when a pull request is made to the "main" branch.
  - **workflow_dispatch**: Allows the workflow to be manually triggered via the GitHub Actions interface.

### Environment Variables

```yaml
env:
  tfcode_path: tfcloud_samples/amazon_ec2
  tfc_organisation: gsaravanan-tf
  tfc_hostname: app.terraform.io
  tfc_workspace: example-workspace
```

- **env**: Sets environment variables that will be used throughout the workflow.
  - **tfcode_path**: Path to the Terraform code directory.
  - **tfc_organisation**: Name of the Terraform Cloud organization.
  - **tfc_hostname**: Hostname of the Terraform Cloud instance.
  - **tfc_workspace**: Name of the Terraform Cloud workspace.

### Jobs Section

#### Job 1: `aws_tfc_job`

```yaml
jobs: 
  aws_tfc_job:
    name: Create AWS Infra Using TFC

    runs-on: ubuntu-latest

    steps:
    - name: Checkout tf code in runner environment
      uses: actions/checkout@v3.5.2
```

- **jobs**: Defines a list of jobs in the workflow. Each job will run in its own runner.
- **aws_tfc_job**: The first job to create AWS infrastructure using Terraform Cloud.
  - **runs-on**: Specifies the type of runner to use. Here, it is `ubuntu-latest`.
  - **steps**: A sequence of tasks to be performed in this job.
    - **Checkout tf code in runner environment**: Uses the `actions/checkout` action to check out the repository code.

#### Setting Up Terraform CLI

```yaml
    - name: Setup Terraform CLI
      uses: hashicorp/setup-terraform@v2.0.2
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}
```

- **Setup Terraform CLI**: Uses the `hashicorp/setup-terraform` action to set up the Terraform CLI with the API token from secrets.

#### Terraform Init and Validate

```yaml
    - name: Terraform init and validate
      run: |
        echo `pwd`
        echo "** Running Terraform Init**"
        terraform init
          
        echo "** Running Terraform Validate**"
        terraform validate
      working-directory: ${{ env.tfcode_path }}
```

- **Terraform init and validate**: Runs Terraform initialization and validation commands.
  - **run**: Specifies the shell commands to execute.
  - **working-directory**: Sets the working directory for the commands.

#### Terraform Plan and Output

```yaml
    - name: Terraform Plan
      uses: hashicorp/tfc-workflows-github/actions/create-run@v1.3.0
      id: run
      with:
        workspace: ${{ env.tfc_workspace }}
        plan_only: true
        message: "Plan Run from GitHub Actions"
        hostname: ${{ env.tfc_hostname }}
        token: ${{ secrets.TF_API_TOKEN }}
        organization: ${{ env.tfc_organisation }}

    - name: Terraform Plan Output
      uses: hashicorp/tfc-workflows-github/actions/plan-output@v1.3.0
      id: plan-output
      with:
        hostname: ${{ env.tfc_hostname }}
        token: ${{ secrets.TF_API_TOKEN }}
        organization: ${{ env.tfc_organisation }}
        plan: ${{ steps.run.outputs.plan_id }}
    
    - name: Reference Plan Output
      run: |
        echo "Plan status: ${{ steps.plan-output.outputs.plan_status }}"
        echo "Resources to Add: ${{ steps.plan-output.outputs.add }}"
        echo "Resources to Change: ${{ steps.plan-output.outputs.change }}"
        echo "Resources to Destroy: ${{ steps.plan-output.outputs.destroy }}"
```

- **Terraform Plan**: Uses the `hashicorp/tfc-workflows-github/actions/create-run` action to create a Terraform plan in Terraform Cloud.
  - **id: run**: Sets an ID for this step to reference its outputs.
  - **with**: Passes parameters to the action, such as the workspace, hostname, token, and organization.
- **Terraform Plan Output**: Uses the `hashicorp/tfc-workflows-github/actions/plan-output` action to get the output of the Terraform plan.
  - **plan**: References the plan ID from the previous step's output.
- **Reference Plan Output**: Prints the plan status and the resources to add, change, and destroy.

#### Job 2: `apply_terraform_plan`

```yaml
  apply_terraform_plan:
      needs: aws_tfc_job
      if: github.event_name == 'workflow_dispatch'
      runs-on: ubuntu-latest
      steps:
      - name: Checkout
        uses: actions/checkout@v3.5.2
      - name: Setup Terraform CLI
        uses: hashicorp/setup-terraform@v2.0.2
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      # Invoke the Terraform commands
      - name: Terraform init and validate
        run: |
          echo `pwd`
          echo "** Running Terraform Init**"
          terraform init
        
          echo "** Running Terraform Validate**"
          terraform validate
        working-directory: ${{ env.tfcode_path }}
      
      - name: Terraform Apply
        run: echo "** Running Terraform Apply**"; terraform apply -auto-approve
        working-directory: ${{ env.tfcode_path }}
  
      - name: Terraform Destroy
        run: echo "** Running Terraform Destroy**"; terraform destroy -auto-approve
        working-directory: ${{ env.tfcode_path }}
```

- **apply_terraform_plan**: The second job to apply the Terraform plan.
  - **needs**: Specifies that this job depends on the successful completion of `aws_tfc_job`.
  - **if**: Runs this job only if the workflow was manually triggered (`workflow_dispatch`).
  - **runs-on**: Specifies the type of runner to use.
  - **steps**: A sequence of tasks to be performed in this job.
    - **Checkout**: Uses the `actions/checkout` action to check out the repository code.
    - **Setup Terraform CLI**: Sets up the Terraform CLI with the API token from secrets.
    - **Terraform init and validate**: Runs Terraform initialization and validation commands.
    - **Terraform Apply**: Applies the Terraform plan.
    - **Terraform Destroy**: Destroys the Terraform-managed infrastructure.

### Summary

This GitHub Actions workflow automates the process of managing AWS infrastructure using Terraform Cloud. It includes steps for checking out code, setting up Terraform CLI, initializing and validating Terraform configurations, creating and retrieving Terraform plans, and optionally applying or destroying the infrastructure. The workflow is designed to be reusable and can be triggered by various events, including manual triggers for specific actions like applying the Terraform plan.