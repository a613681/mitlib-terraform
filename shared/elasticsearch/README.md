# AWS Elasticsearch

We are currently using Amazon's Elasticsearch (ES) service for our Elasticsearch needs. There are currently two ES clusters. One cluster for our `stage` environment, and one for our `prod` environment.

### elasticsearch-stage cluster

This cluster is a single `t2.small.elasticsearch` instance for testing purposes.


### elasticsearch-prod cluster

This cluster contains three `t2.small.elasticsearch` instances across a single availability zone. Given our current minimal Elasticsearch usage, our main priority is to prevent against split-brain versus high availability.

### Future
AWS recently announced [Elasticsearch support across 3 Availability Zones](https://aws.amazon.com/about-aws/whats-new/2019/02/amazon-elasticsearch-service-now-supports-three-availability-zone-deployments/). This will be an ideal solution for our `prod` cluster setup, however this feature is not yet supported by Terraform. An [issue](https://github.com/terraform-providers/terraform-provider-aws/issues/7504) has been created in the [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws) GitHub repo for future support.

We also ran into issues restricting access to the Elasticsearch clusters via IAM policies and using v4 signing from the mario application. As a temporary workaround (and since we're only using this for the Discovery Index Project (DIP) currently), we've added attached an `aws_iam_policy_document` to the cluster in the [Discovery Index Project's Terraform configuration](https://github.com/MITLibraries/mitlib-terraform/blob/master/apps/DIP/dip.tf). This policy allows all access from our private subnets (egress traffic from our NAT Gateways) to the ES cluster. This method should be re-evaluated and improved upon as we expand our usage of Elasticsearch.
