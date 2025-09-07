package provider

import (
	"context"
	"fmt"

	"terraform-provider-example/internal/server"

	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure the implementation satisfies the expected interfaces.
var (
	_ resource.Resource              = &serverResource{}
	_ resource.ResourceWithConfigure = &serverResource{}
)

// NewServerResource is a helper function to simplify the provider implementation.
func NewServerResource() resource.Resource {
	return &serverResource{}
}

// serverResource is the resource implementation.
type serverResource struct {
	// client would be set if we had a real API client
}

// serverResourceModel maps the resource schema data.
type serverResourceModel struct {
	ID        types.String `tfsdk:"id"`
	Name      types.String `tfsdk:"name"`
	IPAddress types.String `tfsdk:"ip_address"`
	Port      types.Int64  `tfsdk:"port"`
}

// Configure adds the provider configured client to the resource.
func (r *serverResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	// In a real provider, you would cast the provider data to a client struct
	// provider, ok := req.ProviderData.(*ExampleClient)
}

// Metadata returns the resource type name.
func (r *serverResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_server"
}

// Schema defines the schema for the resource.
func (r *serverResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Description: "Manages a server instance.",
		Attributes: map[string]schema.Attribute{
			"id": schema.StringAttribute{
				Description: "Identifier of the server.",
				Computed:    true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
			"name": schema.StringAttribute{
				Description: "Name of the server.",
				Required:    true,
			},
			"ip_address": schema.StringAttribute{
				Description: "IP address of the server.",
				Required:    true,
			},
			"port": schema.Int64Attribute{
				Description: "Port number for the server.",
				Optional:    true,
			},
		},
	}
}

// Create creates the resource and sets the initial Terraform state.
func (r *serverResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	// Retrieve values from plan
	var plan serverResourceModel
	diags := req.Plan.Get(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Create new server
	s := server.NewServer()
	s.Name = plan.Name.ValueString()

	// In a real implementation, you would call your API here
	err := s.Create(ctx, plan.Name.ValueString(), plan.IPAddress.ValueString(), int(plan.Port.ValueInt64()))
	if err != nil {
		resp.Diagnostics.AddError(
			"Error creating server",
			fmt.Sprintf("Could not create server, unexpected error: %s", err),
		)
		return
	}

	// Generate resource ID
	plan.ID = types.StringValue(fmt.Sprintf("server-%s", plan.Name.ValueString()))

	// Log the creation
	tflog.Info(ctx, fmt.Sprintf("Created server resource: %s", plan.ID.ValueString()))

	// Set state
	diags = resp.State.Set(ctx, plan)
	resp.Diagnostics.Append(diags...)
}

// Read refreshes the Terraform state with the latest data.
func (r *serverResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	// Get current state
	var state serverResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// In a real implementation, you would call your API here to get the current state
	// server, err := r.client.GetServer(state.ID.ValueString())

	// For this example, we'll just keep the state as is

	// Set refreshed state
	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

// Update updates the resource and sets the updated Terraform state on success.
func (r *serverResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	// Retrieve values from plan
	var plan serverResourceModel
	diags := req.Plan.Get(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Get current state
	var state serverResourceModel
	diags = req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// In a real implementation, you would call your API here to update the resource
	// err := r.client.UpdateServer(state.ID.ValueString(), plan.Name.ValueString(), plan.IPAddress.ValueString(), int(plan.Port.ValueInt64()))

	// Set updated state
	diags = resp.State.Set(ctx, plan)
	resp.Diagnostics.Append(diags...)
}

// Delete deletes the resource and removes the Terraform state on success.
func (r *serverResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	// Retrieve values from state
	var state serverResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// In a real implementation, you would call your API here to delete the resource
	// err := r.client.DeleteServer(state.ID.ValueString())

	// Log the deletion
	tflog.Info(ctx, fmt.Sprintf("Deleted server resource: %s", state.ID.ValueString()))
}
