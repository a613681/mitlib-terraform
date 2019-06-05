module "label_slingshot" {
  source = "git::https://github.com/mitlibraries/tf-mod-name?ref=master"
  name   = "slingshot"
}

module "slingshot_ecr" {
  source = "git::https://github.com/mitlibraries/tf-mod-ecr?ref=master"
  name   = "slingshot"
}

resource "aws_dynamodb_table" "layers" {
  name         = "${module.label_slingshot.name}-layers"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LayerName"
  tags         = "${module.label_slingshot.tags}"

  attribute {
    name = "LayerName"
    type = "S"
  }
}

#######################
## S3 storage bucket ##
#######################
resource "aws_s3_bucket" "slingshot_storage" {
  bucket_prefix = "${module.label_slingshot.name}-storage"
  tags          = "${module.label_slingshot.tags}"
}

data "aws_iam_policy_document" "slingshot_storage" {
  statement {
    actions   = ["s3:*Object"]
    resources = ["${aws_s3_bucket.slingshot_storage.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.slingshot_storage.arn}"]
  }
}

####################
## SSM parameters ##
####################
resource "aws_ssm_parameter" "geoserver_password" {
  name  = "${module.label_slingshot.name}-geoserver-password"
  tags  = "${module.label_slingshot.tags}"
  type  = "SecureString"
  value = "${var.geoserver_password}"
}

data "aws_iam_policy_document" "slingshot_ssm" {
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      "${aws_ssm_parameter.geoserver_password.arn}",
      "${aws_ssm_parameter.postgres_password.arn}",
    ]
  }
}

############################
## Slingshot Fargate task ##
############################
resource "aws_cloudwatch_log_group" "slingshot" {
  name              = "${module.label_slingshot.name}"
  tags              = "${module.label_slingshot.tags}"
  retention_in_days = 30
}

resource "aws_iam_role" "slingshot" {
  name               = "${module.label_slingshot.name}-ecs"
  tags               = "${module.label_slingshot.tags}"
  description        = "Fargate task execution role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"
}

resource "aws_iam_role_policy_attachment" "slingshot_task_exec" {
  role       = "${aws_iam_role.slingshot.name}"
  policy_arn = "${data.aws_iam_policy.ecs_exec.arn}"
}

resource "aws_iam_role_policy" "slingshot_ssm" {
  name   = "${module.label_slingshot.name}-ssm"
  role   = "${aws_iam_role.slingshot.name}"
  policy = "${data.aws_iam_policy_document.slingshot_ssm.json}"
}

resource "aws_iam_role" "slingshot_task" {
  name               = "${module.label_slingshot.name}-ecs-task"
  tags               = "${module.label_slingshot.tags}"
  description        = "Fargate task role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"
}

resource "aws_iam_role_policy" "slingshot_storage" {
  name   = "${module.label_slingshot.name}-s3-storage"
  role   = "${aws_iam_role.slingshot_task.name}"
  policy = "${data.aws_iam_policy_document.slingshot_storage.json}"
}

resource "aws_iam_role_policy_attachment" "slingshot_upload" {
  role       = "${aws_iam_role.slingshot_task.name}"
  policy_arn = "${module.geoweb_upload.readonly_arn}"
}

resource "aws_iam_role_policy_attachment" "slingshot_dynamodb" {
  role       = "${aws_iam_role.slingshot_task.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_ecs_cluster" "slingshot" {
  name = "${module.label_slingshot.name}"
  tags = "${module.label_slingshot.tags}"
}

data "template_file" "slingshot" {
  template = "${file("${path.module}/slingshot.json")}"

  vars = {
    name               = "${module.label_slingshot.name}"
    image              = "${module.slingshot_ecr.registry_url}"
    log_group          = "${aws_cloudwatch_log_group.default.name}"
    pg_user            = "${var.postgres_username}"
    pg_host            = "${module.rds.hostname[0]}"
    pg_name            = "${var.postgres_database}"
    pg_password        = "${aws_ssm_parameter.postgres_password.arn}"
    geoserver_url      = "http://${aws_route53_record.geoserver_dns.fqdn}:8080/geoserver"
    geoserver_user     = "${var.geoserver_username}"
    geoserver_password = "${aws_ssm_parameter.geoserver_password.arn}"
    solr_url           = "http://${aws_route53_record.solr_dns.fqdn}:8983/solr/geoweb"
    dynamo_table       = "${aws_dynamodb_table.layers.name}"
    upload_bucket      = "${module.geoweb_upload.bucket_id}"
    storage_bucket     = "${aws_s3_bucket.slingshot_storage.id}"
  }
}

resource "aws_ecs_task_definition" "slingshot" {
  family                   = "${module.label_slingshot.name}"
  container_definitions    = "${data.template_file.slingshot.rendered}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.slingshot.arn}"
  task_role_arn            = "${aws_iam_role.slingshot_task.arn}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  tags                     = "${module.label_slingshot.tags}"
}

data "template_file" "slingshot_init" {
  template = "${file("${path.module}/slingshot-init.json")}"

  vars = {
    name               = "${module.label_slingshot.name}-init"
    image              = "${module.slingshot_ecr.registry_url}"
    log_group          = "${aws_cloudwatch_log_group.default.name}"
    geoserver_url      = "http://${aws_route53_record.geoserver_dns.fqdn}:8080/geoserver"
    geoserver_user     = "${var.geoserver_username}"
    geoserver_password = "${aws_ssm_parameter.geoserver_password.arn}"
    pg_user            = "${var.postgres_username}"
    pg_host            = "${module.rds.hostname[0]}"
    pg_name            = "${var.postgres_database}"
    pg_password        = "${aws_ssm_parameter.postgres_password.arn}"
  }
}

resource "aws_ecs_task_definition" "slingshot_init" {
  family                   = "${module.label_slingshot.name}-init"
  container_definitions    = "${data.template_file.slingshot_init.rendered}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${aws_iam_role.slingshot.arn}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  tags                     = "${module.label_slingshot.tags}"
}
