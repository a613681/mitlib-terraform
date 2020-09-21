# Shared deploy resource

This module provides a shared place for various deploy related resources. Currently, this just contains an S3 bucket that can be used for binaries needed during deploy.

### What's created
* IAm access policy for an S3 bucket
* S3 bucket

## Outputs

| Name | Description |
|------|-------------|
| name | Bucket name |
| rw\_arn | Read/write policy ARN |
