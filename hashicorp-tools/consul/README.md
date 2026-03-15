# Consul – Service Discovery for 2-Tier AWS App

Deploy a **HashiCorp Consul** cluster on AWS for service discovery, health checking, and service mesh for the 2-tier application.

## Features

- 3-node Consul server cluster (production quorum)
- EC2 auto-join via AWS instance tags (no hardcoded IPs)
- Consul Connect service mesh enabled
- IMDSv2 enforced on all instances
- Prometheus metrics endpoint

## Service Registration

Consul client agents on web/app tier instances register services:

```hcl
# /etc/consul.d/web-service.hcl (on web instances)
service {
  name = "web-server"
  port = 80
  check {
    http     = "http://localhost/health"
    interval = "10s"
    timeout  = "2s"
  }
}
```

```hcl
# /etc/consul.d/app-service.hcl (on app instances)
service {
  name = "app-server"
  port = 3000
  check {
    http     = "http://localhost:3000/health"
    interval = "10s"
    timeout  = "2s"
  }
}
```

## DNS Resolution

Consul DNS allows services to discover each other:

```bash
# Resolve app server instances
dig @127.0.0.1 -p 8600 app-server.service.consul

# Nginx proxy uses DNS: http://app-server.service.consul:3000
```

## Usage

```bash
terraform init
terraform plan -var="vpc_id=vpc-xxx" -var="consul_ami_id=ami-xxx"
terraform apply
```
