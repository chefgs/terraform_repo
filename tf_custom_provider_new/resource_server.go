// resource_server.go
package main

import (
        "strings"
        "net/http"
        "log"
        "github.com/hashicorp/terraform-plugin-sdk/helper/schema"
)

func resourceServer() *schema.Resource {
        return &schema.Resource{
                Create: resourceServerCreate,
                Read:   resourceServerRead,
                Update: resourceServerUpdate,
                Delete: resourceServerDelete,

                Schema: map[string]*schema.Schema{
                        "uuid_count": &schema.Schema{
                                Type:     schema.TypeString,
                                Required: true,
                        },
                },
        }
}

func resourceServerCreate(d *schema.ResourceData, m interface{}) error {
        uuid_count := d.Get("uuid_count").(string)

        d.SetId(uuid_count)

        // https://www.uuidtools.com/api/generate/v1/count/uuid_count
        body := strings.NewReader(uuid_count)
        req, err := http.NewRequest("GET", "https://www.uuidtools.com/api/generate/v1/count/", body)
        if err != nil {
                log.Fatal(err)
        }
        req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
        resp, err := http.DefaultClient.Do(req)
        if err != nil {
                log.Fatal(err)
        }
        defer resp.Body.Close()

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

