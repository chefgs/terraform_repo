## Terraform Code Repo for Major Cloud Providers and Custom Provider Guide

- [x] [![AWS Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml)
- [ ] Azure Workflow - ToDo
- [ ] GCP Workflow - ToDo
- [ ] DigitalOcean Workflow - ToDo


## Information about this project
- Idea for this open source repository is to collate the Terraform Resource Creation code for Major Cloud Providers
- Also it has sample code for *How to develop Terraform Custom Provider*
- Feel free to explore the repo content, and add :star: or fork if you like the content
- Repo is open for contributions and if you want to contribute please read the **important notice** for contribution guidelines

## Read before you start contributing to this repo
- Read [Contribution Guidelines](./CONTRIBUTING.md) before contributing to this repository!

- Read GitHub [Code Of Conduct guidelines](./CODE_OF_CONDUCT.md)before contributing to this repository!

- Feel free to pick up any of the open [Issues](https://github.com/chefgs/terraform_repo/issues) or create new issue using the [template](https://github.com/chefgs/terraform_repo/issues/new/choose)!

- This repo also has GitHub action [Terraform AWS workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation.yml) to check the Terraform AWS resource code is valid and works fine. Please utilize it for checking the terraform code you're creating. All you've to do is,
  - Open Workflow in "Actions" Tab
  - Click on `Run Workflow`
  - Choose you `branch_name` and Enter your `tf file path` on which you want to run the workflow
  - Check if the workflow is passing or not. Fix the issue in case of failure.

### Good to Have: Create documentation to list down resources/modules/providers/output
- Please install [`terraform-docs`](https://github.com/terraform-docs/terraform-docs/#what-is-terraform-docs) CLI utility to generate documentation for Terraform Code.
- After installing the utility, please run the below command to create markdown document
```
terraform-docs markdown table --output-file TF_README.md --output-mode inject <your-terraform-code-directory>
```
- Please use below command for generating docs recursively for all the Terraform code modules
```
~/go/bin/terraform-docs markdown table --output-file TF_README.md --recursive --recursive-path "<terraform-code-module-path>" --output-mode inject .
```

### Note: 
I've renamed the default branch from `master` to `main`. So If you've cloned my repo locally, then please follow the steps mentioned in [this document](https://dev.to/chefgs/git-101-rename-default-branch-from-master-to-main-5bf4#steps-to-rename-the-other-users-local-repo) to rename your local repo from `master` to `main`

- Feel free to browse through the branch and [post](mailto:g.gsaravanan@gmail.com) any questions to me.
- [LinkedIn](https://www.linkedin.com/in/saravanan-gnanaguru-1941a919/) - Saravanan Gnanaguru

:computer: Happy contributing to the Community!!

**Finally, contributors profile link**

<a href="https://github.com/chefgs/terraform_repo/graphs/contributors">
 <img src="https://contrib.rocks/image?repo=chefgs/terraform_repo" />
</a>
