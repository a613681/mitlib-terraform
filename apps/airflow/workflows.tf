resource "aws_ecs_task_definition" "example" {
  family = "${module.label.name}-example-task"
  tags   = module.label.tags
  container_definitions = templatefile(
    "${path.module}/tasks/example.json",
    {
      "log_group"  = aws_cloudwatch_log_group.default.name
      "log_prefix" = "example-task"
      "command"    = ["worker"]
  })
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.airflow.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}
