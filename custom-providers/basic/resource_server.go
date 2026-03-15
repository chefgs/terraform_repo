// resource_server.go
package main

import (
        "github.com/hashicorp/terraform-plugin-sdk/helper/schema"
)

func resourceServer() *schema.Resource {
        return &schema.Resource{
                Create: resourceServerCreate,
                Read:   resourceServerRead,
                Update: resourceServerUpdate,
                Delete: resourceServerDelete,

                Schema: map[string]*schema.Schema{
                        "num_sys": &schema.Schema{
                                Type:     schema.TypeString,
                                Required: true,
                        },
                },
        }
}

func resourceServerCreate(d *schema.ResourceData, m interface{}) error {
        num_sys := d.Get("num_sys").(string)

        d.SetId(num_sys)

/*
        // In case of developing provider for on-prem cloud or public cloud
        // Not supported by terraform, add the API call to corresponding Resource creation API 
*/
        return resourceServerRead(d, m)
}

func resourceServerRead(d *schema.ResourceData, m interface{}) error {
        return nil
}

func resourceServerUpdate(d *schema.ResourceData, m interface{}) error {
        return resourceServerRead(d, m)
}

func resourceServerDelete(d *schema.ResourceData, m interface{}) error {
        return nil
}

