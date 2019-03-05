module "label" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "author-lookup"
}

module "bucket" {
  source = "git::https://github.com/mitlibraries/tf-mod-s3-iam?ref=master"
  name   = "author-lookup"
}

module "secret" {
  source = "git::https://github.com/mitlibraries/tf-mod-secrets?ref=master"
  name   = "author-lookup"
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:*",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ResetNetworkInterfaceAttribute",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "kinesis:*",
    ]

    resources = [
      "arn:aws:kinesis:*:*:*",
    ]
  }

  statement {
    actions = [
      "sns:*",
    ]

    resources = [
      "arn:aws:sns:*:*:*",
    ]
  }

  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      "arn:aws:sqs:*:*:*",
    ]
  }

  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:*:*:*",
    ]
  }

  statement {
    actions = [
      "route53:*",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type = "Service"

      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com",
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "default" {
  name   = "${module.label.name}-lambda"
  role   = "${aws_iam_role.default.name}"
  policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role" "default" {
  name               = "${module.label.name}-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
  description        = "Role used by author lookup lambda"
  tags               = "${module.label.tags}"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${module.secret.read_policy}"
}

resource "aws_iam_user" "default" {
  name = "${module.label.name}-deploy"
  tags = "${module.label.tags}"
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:InvokeFunction",
      "lambda:ListVersionsByFunction",
      "lambda:RemovePermission",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "iam:PassRole",
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources",
      "cloudformation:UpdateStack",
      "apigateway:OPTIONS",
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "events:DeleteRule",
      "events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:ListRuleNamesByTarget",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_user_policy" "deploy" {
  name   = "${module.label.name}-deploy"
  policy = "${data.aws_iam_policy_document.deploy.json}"
  user   = "${aws_iam_user.default.name}"
}

resource "aws_iam_user_policy_attachment" "default" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.bucket.readwrite_arn}"
}

resource "aws_iam_user_policy_attachment" "deploy" {
  user       = "${aws_iam_user.default.name}"
  policy_arn = "${module.shared.deploy_rw_arn}"
}

resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}
