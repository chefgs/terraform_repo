## Go env setup 
```
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
tar -C /usr/local -xvzf go1.14.2.linux-amd64.tar.gz
mkdir -p go/src go/pkg go/bin
```
## Add Below env vars to .profile
```
export "PATH=$PATH:/usr/local/go/bin"
export "GOPATH=$HOME/go"
export "GOBIN=$GOPATH/bin"
source ~/.profile
go version
```

## Terraform setup
```
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
mv terraform /usr/local/bin/
```
`If terraform executable stored in anyother path, make sure the path is added in $PATH variable permenantly.`

## Build go code and create tf provider executable
```
cd tf_custom_provider/
go mod init
go mod tidy
go build -o terraform-provider-customprovider
```
```
Third-party plugins (both providers and provisioners) can be manually installed into the user plugins directory
Located at %APPDATA%\terraform.d\plugins on Windows and ~/.terraform.d/plugins on other systems.
```
## Create terraform file and crate/destroy resource
```
vim main.tf
terraform init
terraform plan
terraform apply
```
terraform destroy
