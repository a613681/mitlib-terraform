This module sets up the scheduled tasks to run carbon for both the HR
and the AA feeds. The tasks are scheduled by Cloudwatch and run on
Fargate.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ftp\_host | Hostname of FTP server | string | - | yes |
| ftp\_path | A map with the FTP path to the file keyed to the feed type (articles, people) | map | - | yes |
| ftp\_user | FTP username | string | - | yes |
| schedule | A map with the cron schedule expression keyed to the feed type (articles, people) | map | - | yes |
| email | An E-mail address to send the SNS notifications to | string | - | yes |
