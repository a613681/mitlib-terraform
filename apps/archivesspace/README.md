# ArchivesSpace SaaS Application

This folder contains the AWS resources needed to support the ArchivesSpace SaaS application. ArchivesSpace is a web based archives information management system.

This infrastructure currently consists of DNS CName entries in the mitlib.net zone that allow mit.edu zone CNames to be redirected to DNS CName records at the SaaS provider. The use of the mitlib.net zone CNames provides a layer of abstraction that allows MIT Libraries to make vendor requested DNS changes with out requiring updates to the mit.edu zone files.

### Additional Info
* This infrastructure is only created in our Terraform `prod` workspace.

### What's Created
* Route53 mitlib.net CName records.

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| r53\_archivesspace\_cname\_public\_value | The archivesspace public CName DNS record value | list(string) | n/a | yes |
| r53\_archivesspace-staff\_cname\_public\_value | The archivesspace\-staff public CName DNS record value | list(string) | n/a | yes |
| r53\_emmas\-lib\_cname\_public\_value | The emmas\-lib public CName DNS record value | list(string) | n/a | yes |
| r53\_emmastaff\-lib\_cname\_public\_value | The emmastaff\-lib public CName DNS record value | list(string) | n/a | yes |
| r53\_archivesspace\_cname\_private\_value | The archivesspace private CName DNS record value | list(string) | n/a | yes |
