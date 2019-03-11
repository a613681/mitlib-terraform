data "aws_iam_policy_document" "cost" {
  statement {
    sid    = "CloudCheckrCostPermissions"
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeReservedInstancesOfferings",
      "ec2:DescribeReservedInstances",
      "ec2:DescribeReservedInstancesListings",
      "ec2:DescribeHostReservationOfferings",
      "ec2:DescribeReservedInstancesModifications",
      "ec2:DescribeHostReservations",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeKeyPairs",
      "ec2:DescribePlacementGroups",
      "ec2:DescribeAddresses",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeImages",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeVolumeStatus",
      "elasticache:DescribeReservedCacheNodes",
      "elasticache:DescribeReservedCacheNodesOfferings",
      "rds:DescribeReservedDBInstances",
      "rds:DescribeReservedDBInstancesOfferings",
      "rds:DescribeDBInstances",
      "redshift:DescribeReservedNodes",
      "redshift:DescribeReservedNodeOfferings",
      "s3:GetBucketACL",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
      "s3:GetBucketWebsite",
      "s3:GetBucketNotification",
      "s3:GetLifecycleConfiguration",
      "s3:GetNotificationConfiguration",
      "s3:List*",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeReservedCapacityOfferings",
      "iam:GetAccountAuthorizationDetails",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "security" {
  statement {
    sid    = "SecurityPermissons"
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "logs:GetLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "config:DescribeConfigRules",
      "config:GetComplianceDetailsByConfigRule",
      "config:DescribeDeliveryChannels",
      "config:DescribeDeliveryChannelStatus",
      "config:DescribeConfigurationRecorders",
      "config:DescribeConfigurationRecorderStatus",
      "ec2:Describe*",
      "iam:Get*",
      "iam:List*",
      "iam:GenerateCredentialReport",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:ListKeys",
      "kms:ListKeyPolicies",
      "kms:ListResourceTags",
      "rds:Describe*",
      "ses:ListIdentities",
      "ses:GetSendStatistics",
      "ses:GetIdentityDkimAttributes",
      "ses:GetIdentityVerificationAttributes",
      "ses:GetSendQuota",
      "sns:GetSnsTopic",
      "sns:GetTopicAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListTopics",
      "sns:ListSubscriptionsByTopic",
      "sqs:ListQueues",
      "sqs:GetQueueAttributes",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "billing" {
  statement {
    sid    = "CostReadDBR"
    effect = "Allow"

    actions = [
      "s3:GetBucketACL",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
      "s3:GetBucketWebsite",
      "s3:GetBucketNotification",
      "s3:GetLifecycleConfiguration",
      "s3:GetNotificationConfiguration",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::672626379771-dlt-utilization/",
      "arn:aws:s3:::672626379771-dlt-utilization/*",
    ]
  }
}

data "aws_iam_policy_document" "inventory" {
  statement {
    sid    = "InventoryAndUtilization"
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:Describe*",
      "ec2:GetConsoleOutput",
      "autoscaling:Describe*",
      "cloudformation:DescribeStacks",
      "cloudformation:GetStackPolicy",
      "cloudformation:GetTemplate",
      "cloudformation:ListStackResources",
      "cloudfront:List*",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetStreamingDistributionConfig",
      "cloudhsm:Describe*",
      "cloudhsm:List*",
      "cloudsearch:Describe*",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cognito-identity:ListIdentities",
      "cognito-identity:ListIdentityPools",
      "cognito-idp:ListGroups",
      "cognito-idp:ListIdentityProviders",
      "cognito-idp:ListUserPools",
      "cognito-idp:ListUsers",
      "cognito-idp:ListUsersInGroup",
      "config:DescribeConfigRules",
      "config:GetComplianceDetailsByConfigRule",
      "config:Describe*",
      "datapipeline:ListPipelines",
      "datapipeline:GetPipelineDefinition",
      "datapipeline:DescribePipelines",
      "directconnect:DescribeLocations",
      "directconnect:DescribeConnections",
      "directconnect:DescribeVirtualInterfaces",
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:ListTagsOfResource",
      "ecs:ListClusters",
      "ecs:DescribeClusters",
      "ecs:ListContainerInstances",
      "ecs:DescribeContainerInstances",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ssm:ListResourceDataSync",
      "ssm:ListAssociations",
      "ssm:ListDocumentVersions",
      "ssm:ListDocuments",
      "ssm:ListInstanceAssociations",
      "ssm:ListInventoryEntries",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticbeanstalk:Describe*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:List*",
      "es:ListDomainNames",
      "es:DescribeElasticsearchDomains",
      "glacier:ListTagsForVault",
      "glacier:DescribeVault",
      "glacier:GetVaultNotifications",
      "glacier:DescribeJob",
      "glacier:GetJobOutput",
      "glacier:ListJobs",
      "glacier:ListVaults",
      "iam:Get*",
      "iam:List*",
      "iam:GenerateCredentialReport",
      "iot:DescribeThing",
      "iot:ListThings",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:ListKeys",
      "kms:ListKeyPolicies",
      "kms:ListResourceTags",
      "kinesis:ListStreams",
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "lambda:ListFunctions",
      "lambda:ListTags",
      "Organizations:List*",
      "Organizations:Describe*",
      "rds:Describe*",
      "rds:List*",
      "redshift:Describe*",
      "route53:ListHealthChecks",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "s3:GetBucketACL",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketTagging",
      "s3:GetBucketWebsite",
      "s3:GetBucketNotification",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetNotificationConfiguration",
      "s3:List*",
      "sdb:ListDomains",
      "sdb:DomainMetadata",
      "ses:ListIdentities",
      "ses:GetSendStatistics",
      "ses:GetIdentityDkimAttributes",
      "ses:GetIdentityVerificationAttributes",
      "ses:GetSendQuota",
      "sns:GetSnsTopic",
      "sns:GetTopicAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListTopics",
      "sns:ListSubscriptionsByTopic",
      "sqs:ListQueues",
      "sqs:GetQueueAttributes",
      "storagegateway:Describe*",
      "storagegateway:List*",
      "support:*",
      "swf:ListClosedWorkflowExecutions",
      "swf:ListDomains",
      "swf:ListActivityTypes",
      "swf:ListWorkflowTypes",
      "workspaces:DescribeWorkspaceDirectories",
      "workspaces:DescribeWorkspaceBundles",
      "workspaces:DescribeWorkspaces",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid    = "CloudWatchLog"
    effect = "Allow"

    actions = [
      "logs:GetLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "cloudcheckr_role" {
  name        = "CloudCheckrRole"
  description = "Role used by Cloudcheckr.com"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::352813966189:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.external_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cost" {
  name   = "cloudcheckr-cost"
  role   = "${aws_iam_role.cloudcheckr_role.name}"
  policy = "${data.aws_iam_policy_document.cost.json}"
}

resource "aws_iam_role_policy" "security" {
  name   = "cloudcheckr-security"
  role   = "${aws_iam_role.cloudcheckr_role.name}"
  policy = "${data.aws_iam_policy_document.security.json}"
}

resource "aws_iam_role_policy" "billing" {
  name   = "cloudcheckr-billing"
  role   = "${aws_iam_role.cloudcheckr_role.name}"
  policy = "${data.aws_iam_policy_document.billing.json}"
}

resource "aws_iam_role_policy" "inventory" {
  name   = "cloudcheckr-inventory"
  role   = "${aws_iam_role.cloudcheckr_role.name}"
  policy = "${data.aws_iam_policy_document.inventory.json}"
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "cloudcheckr-cloudwatch"
  role   = "${aws_iam_role.cloudcheckr_role.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch.json}"
}
