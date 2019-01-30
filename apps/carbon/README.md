This module sets up the scheduled tasks to run carbon for both the HR
and the AA feeds. The tasks are scheduled by Cloudwatch and run on
Fargate.

# HR Feed
The dev feed will be run the 1st Monday of every month at 10AM `cron(0 10 ? * 2#1 *)`. The prod feed will be run on the 4th Monday of July `cron(0 10 ? 7 2#4 *)` and the second Monday of January `cron(0 10 ? 1 2#2 *)`.

# AA Feed
The dev feed will be run on the 1st Monday of every month at 10AM `cron(0 10 ? * 2#1 *)`. The prod feed will be run on the 2nd Monday of every month at 10AM `cron(0 10 ? * 2#2 *)`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ftp\_host | Hostname of FTP server | string | - | yes |
| ftp\_path | A map with the FTP path to the file keyed to the feed type (articles, people) | map | - | yes |
| ftp\_user | FTP username | string | - | yes |
| schedule | A map with the cron schedule expression keyed to the feed type (articles, people) | map | - | yes |
| email | An E-mail address to send the SNS notifications to | string | - | yes |
