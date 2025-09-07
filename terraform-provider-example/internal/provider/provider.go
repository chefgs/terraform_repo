package provider

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure the implementation satisfies the expected interfaces
var (
	_ provider.Provider = &exampleProvider{}
)

// exampleProvider is the provider implementation.
type exampleProvider struct {
	// version is set to the provider version on release, "dev" when the
	// provider is built and ran locally, and "test" when running acceptance
	// testing.
	version string
}

// exampleProviderModel maps provider schema data to a Go type.
type exampleProviderModel struct {
	ExampleSetting types.String `tfsdk:"example_setting"`
}

// New returns a new example provider with the default configurations
func New(version string) func() provider.Provider {
	return func() provider.Provider {
		return &exampleProvider{
			version: version,
		}
	}
}

// Metadata returns the provider type name.
func (p *exampleProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "example"
	resp.Version = p.version
}

// Schema defines the provider-level schema for configuration data.
func (p *exampleProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{
		Description: "Example provider for demonstrating Terraform Plugin Framework usage.",
		Attributes: map[string]schema.Attribute{
			"example_setting": schema.StringAttribute{
				Description: "An example setting for the provider.",
				Optional:    true,
			},
		},
	}
}

// Configure prepares a example API client for data sources and resources.
func (p *exampleProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
	// Retrieve provider data from configuration
	var config exampleProviderModel
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// In a real provider, you would configure a client here with the API
	// credentials or other configuration from the provider config.
	// For this example, we'll just pass an empty value.
	resp.ResourceData = nil
	resp.DataSourceData = nil
}

// DataSources defines the data sources implemented in the provider.
func (p *exampleProvider) DataSources(_ context.Context) []func() datasource.DataSource {
	return []func() datasource.DataSource{}
}

// Resources defines the resources implemented in the provider.
func (p *exampleProvider) Resources(_ context.Context) []func() resource.Resource {
	return []func() resource.Resource{
		NewServerResource,
	}
}
