# Simile-widgets
This folder contains AWS Route53 records for the simile-widgets.org websites.

### What's created?:
* Route53 zone for simile-widgets.org
* Route53 NS and SOA DNS records for the simile-widgets.org domain
* Route53 DNS A record entries for simile-widgets.org websites

### Additional Info:
* This infrastructure is only created in our Terraform `prod` workspace.

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_api\_value | The api.simile\-widgets.org website DNS record value | list(string) | n/a | yes |
| r53\_service\_value | The service.simile\-widgets.org website DNS record value | list(string) | n/a | yes |
| r53\_trunk\_value | The trunk.simile\-widgets.org website DNS record value | list(string) | n/a | yes |
| r53\_web\_value | The simile\-widgets.org website DNS record value | list(string) | n/a | yes |
