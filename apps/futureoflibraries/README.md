# Future of Libraries

This folder contains AWS Route53 records for the Future of Libraries Drupal site hosted on [Pantheon](https://pantheon.io/).

### What's created?:
* 3 x Route53 DNS records for dev, test, and prod

### Additional Info:
* Future of Libraries is only deployed to the Terraform `prod` workspace

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_fol\_value | The prod future\-of\-libraries.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_fol\_dev\_value | The future\-of\-libraries\-dev.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
| r53\_fol\_test\_value | The future\-of\-libraries\-test.mitlib.net website DNS CNAME record value | list(string) | n/a | yes |
