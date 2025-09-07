# GNUmakefile

default: testacc

# Run acceptance tests
.PHONY: testacc
testacc:
	TF_ACC=1 go test ./... -v $(TESTARGS) -timeout 120m

# Install provider locally for testing
.PHONY: install
install: build
	mkdir -p ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/darwin_amd64/
	cp terraform-provider-example ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/darwin_amd64/
	mkdir -p ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/darwin_arm64/
	cp terraform-provider-example ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/darwin_arm64/

# Build the provider
.PHONY: build
build:
	go build -o terraform-provider-example

# Clean build artifacts
.PHONY: clean
clean:
	go clean
	rm -f terraform-provider-example

# Run go mod tidy
.PHONY: tidy
tidy:
	go mod tidy

# Generate documentation
.PHONY: docs
docs:
	go generate ./...