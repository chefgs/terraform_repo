# Terraform Custom Provider Development Guide
## Step1: Go env setup 
```
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
tar -C /usr/local -xvzf go1.14.2.linux-amd64.tar.gz
mkdir -p go/src go/pkg go/bin
```
## Step2: Add Below env vars to .profile
```
export "PATH=$PATH:/usr/local/go/bin"
export "GOPATH=$HOME/go"
export "GOBIN=$GOPATH/bin"
source ~/.profile
go version
```

## Step3: Terraform setup
```
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
mv terraform /usr/local/bin/
```
`If terraform executable stored in anyother path, make sure the path is added in $PATH variable permenantly.`

## Why custom provider development required?
According to Terraform documentation, 

There are a few possible reasons for authoring a custom Terraform provider, such as:

1. An internal private cloud whose functionality is either proprietary or would not benefit the open source community.

2. A "work in progress" provider being tested locally before contributing back.

3. Extensions of an existing provider

Refer the Hashicorp Documentation on [writing custom providers](https://www.terraform.io/docs/extend/writing-custom-providers.html)

## How to develop provider code with Go
### Highlevel Steps
1. Required source files `main.go`, `provider.go`, `resource_server.go`

2. The resource server functions has to be called in the `provider.go`. Go entry point function is `main.go`.

3. `resource_server.go` will have the resource function declaration and definition like create, delete etc, it also gets the input params required to create resources. 
```
The code layout looks like this:
.
├── main.go
├── provider.go
├── resource_server.go
```
4. Our code repo example implemented with mock resource creation for the provider called 'customprovider'. In real-time case, it has to be changed for the provider name of respective cloud or on-premises server. Most of proivders have API calls to be consumed for resource operation like create/update/delete etc.. So We need to define the logic of resource operations like create and delete using the custom provider api calls, to apply the terraform template.

5. Test the provider by creating `main.tf`, by providing the resource inputs. (execute `terraform init`). In our code sample just the number of server count added as an input parameter.

6. After adding the logic for resource operations, we can try "terraform apply" command to check the resource operation 

7. The custom provider executable should be placed inside the "~/.terraform.d/plugins" (in Linux server) path to enable the access to the custom provider functionality

## Step4: Build go code and create tf provider executable
```
cd tf_custom_provider/
go mod init
go mod tidy
go build -o terraform-provider-customprovider
```
```
Third-party plugins (both providers and provisioners) can be manually installed into the user plugins directory
Located at %APPDATA%\terraform.d\plugins on Windows and ~/.terraform.d/plugins on other systems.

Copy the custom provider executable created in the step above to Terraform plugin directory
```
## Step5: Create terraform file and crate/destroy resource
```
vim main.tf
terraform init
terraform plan
terraform apply
terraform destroy
```
