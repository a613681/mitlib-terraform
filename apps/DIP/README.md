# Discovery Index Pipeline

This module contains the configuration for the Discovery Index Pipeline. The main pieces of infrastructure include several new roles and policies, along with the following:

* S3 bucket for the Aleph MARC upload
* S3 bucket for the mario-powerup Lambda deployment package
* ECR registry for the mario container
* [mario-powerup](https://github.com/MITLibraries/mario-powerup) Lambda function
* [mario](https://github.com/MITLibraries/mario) Fargate task
* User for Aleph submission with permissions to submit to the Aleph bucket
* User for timdex with read permissions on the Elasticsearch index
* User for deploying mario container and mario-power Lambda function

The Elasticsearch search cluster is created in the [shared module](https://github.com/MITLibraries/mitlib-terraform/tree/master/shared/elasticsearch).

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access key ID for the Aleph submission to S3 user |
| mario\_deploy\_access\_key\_id | Access key ID for the mario deploy user |
| mario\_deploy\_secret\_access\_key | Secret access key for mario deploy user. |
| secret\_access\_key | Secret access key for the Aleph submission to S3 user |
