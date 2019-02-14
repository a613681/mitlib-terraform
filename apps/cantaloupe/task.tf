# Create task in JSON format for ECS
module "task" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition?ref=tags/0.7.0"
  container_name   = "${module.label.name}"
  container_image  = "${module.ecr.registry_url}:latest"
  container_cpu    = "2048"
  container_memory = "4096"

  log_options = {
    "awslogs-region"        = "us-east-1"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "cantaloupe"
  }

  port_mappings = [
    {
      containerport = 8182
      protocol      = "tcp"
    },
  ]

  environment = [
    {
      name  = "ENDPOINT_ADMIN_ENABLED"
      value = "${var.endpoint_admin_enabled}"
    },
    {
      name  = "ENDPOINT_ADMIN_SECRET"
      value = "${var.admin_pass}"
    },
    {
      name  = "S3SOURCE_ENDPOINT"
      value = "s3.us-east-1.amazonaws.com"
    },
    {
      name  = "SOURCE_STATIC"
      value = "S3Source"
    },
    {
      name  = "S3SOURCE_LOOKUP_STRATEGY"
      value = "BasicLookupStrategy"
    },
    {
      name  = "S3SOURCE_BASICLOOKUPSTRATEGY_PATH_PREFIX"
      value = ""
    },
    {
      name  = "S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX"
      value = ""
    },
    {
      name  = "S3SOURCE_ACCESS_KEY_ID"
      value = "${aws_iam_access_key.s3store.id}"
    },
    {
      name  = "S3SOURCE_SECRET_KEY"
      value = "${aws_iam_access_key.s3store.secret}"
    },
    {
      name  = "S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME"
      value = "${module.s3store.bucket_id}"
    },
    {
      name  = "S3CACHE_ACCESS_KEY_ID"
      value = "${aws_iam_access_key.s3cache.id}"
    },
    {
      name  = "S3CACHE_SECRET_KEY"
      value = "${aws_iam_access_key.s3cache.secret}"
    },
    {
      name  = "S3CACHE_BUCKET_NAME"
      value = "${module.s3cache.bucket_id}"
    },
    {
      name  = "CACHE_SERVER_DERIVATIVE"
      value = "S3Cache"
    },
    {
      name  = "S3CACHE_OBJECT_KEY_PREFIX"
      value = ""
    },
    {
      name  = "PROCESSOR_JP2"
      value = "OpenJpegProcessor"
    },
    {
      name  = "PROCESSOR_JPG_QUALITY"
      value = "80"
    },
    {
      name  = "PROCESSOR_TIF_COMPRESSION"
      value = "LZW"
    },
    {
      name  = "LOG_APPLICATION_LEVEL"
      value = "warn"
    },
  ]
}
