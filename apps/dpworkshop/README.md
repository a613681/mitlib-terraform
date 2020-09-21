# DPWorkshop

This folder contains AWS Route53 records for dpworkshop.org sites hosted on [Pantheon](https://pantheon.io/).

### Additional Info:
* This infrastructure is only created in our Terraform `prod` workspace.

### What's created?:
* dpworkshop.org Route53 Hosted zone
* Associated NS and SOA records for the dpworkshop.org domain
* Route53 DNS records for dev, test, and prod (dpworkshop.org)
* Route53 DNS records for dev, test, and prod (tdr.dpworkshop.org)

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_dpworkshop\_prod_value | The prod dpworkshop.org website DNS record value | list(string) | n/a | yes |
| r53\_dpworkshop\_prod\_ipv6_value | The prod dpworkshop.org website IPv6 DNS record value | list(string) | n/a | yes |
| r53\_dpworkshop\_dev\_value | The dev.dpworkshop.org website DNS CNAME record value | list(string) | n/a | yes |
| r53\_dpworkshop\_test\_value | The test.dpworkshop.org website DNS CNAME record value | list(string) | n/a | yes |
| r53\_tdr\_value | The prod tdr.dpworkshop.org Trac website DNS CNAME record value | list(string) | n/a | yes |
| r53\_tdr\_dev\_value | The tdr\-dev.dpworkshop.org Trac website DNS CNAME record value | list(string) | n/a | yes |
| r53\_tdr\_test\_value | The tdr\-test.dpworkshop.org Trac website DNS CNAME record value | list(string) | n/a | yes |
