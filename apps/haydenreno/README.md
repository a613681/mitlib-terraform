# Hayden Renovation Site

This folder contains AWS Route53 records for the Hayden Renovation WordPress site hosted on [Pantheon](https://pantheon.io/).

### What's created?:
* 3 x Route53 DNS records for dev, test, and prod

### Additional Info:
* Hayden Renovation is only deployed to the Terraform `prod` workspace

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_haydenreno\_value | The prod haydenrenonews.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_haydenreno\_dev\_value | The haydenrenonews\-dev.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_haydenreno\_test\_value | The haydenrenonews\-test.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
