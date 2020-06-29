```
  Enter a value: yes

customprovider_server.my-server-name: Creating...
customprovider_server.my-server-name: Creation complete after 0s [id=2]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
root@golearn:~/go/src/tf_custom_provider# terraform destroy
customprovider_server.my-server-name: Refreshing state... [id=2]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # customprovider_server.my-server-name will be destroyed
  - resource "customprovider_server" "my-server-name" {
      - id      = "2" -> null
      - num_sys = "2" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

customprovider_server.my-server-name: Destroying... [id=2]
customprovider_server.my-server-name: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```
