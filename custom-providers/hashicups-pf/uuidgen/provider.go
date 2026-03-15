// provider.go
package uuidgen

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		ResourcesMap: map[string]*schema.Resource{
			"example_server": resourceServer(),
		},
	}
}

// Ensure the implementation satisfies the expected interfaces
var (
	_ provider.Provider = &uuidgenProvider{}
)

// New is a helper function to simplify provider server and testing implementation.
func New() provider.Provider {
	return &uuidgenProvider{}
}

// uuidgenProvider is the provider implementation.
type uuidgenProvider struct{}

// Metadata returns the provider type name.
func (p *uuidgenProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "uuidgen"
}

// Schema defines the provider-level schema for configuration data.
func (p *uuidgenProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{}
}

// Configure prepares a HashiCups API client for data sources and resources.
func (p *uuidgenProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
}

// DataSources defines the data sources implemented in the provider.
func (p *uuidgenProvider) DataSources(_ context.Context) []func() datasource.DataSource {
	return nil
}

// Resources defines the resources implemented in the provider.
func (p *uuidgenProvider) Resources(_ context.Context) []func() resource.Resource {
	return nil
}
