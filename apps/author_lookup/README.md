# Author Lookup API

This module contains partial configuration for the Author Lookup API. The following items are created:

* Lambda exection role
* Travis deploy user
* S3 bucket for Lambda
* Secret used by API

The rest of the AWS resources are created/managed by zappa during deploy.

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access key for deploy user |
| bucket\_name | Name of Lambda bucket |
| deploy\_user | Name of the IAM deploy user |
| role\_arn | ARN for Zappa execution role |
| secret\_access\_key | Secret key for deploy user |
| secrets\_arn | ARN for author lookup secrets |

