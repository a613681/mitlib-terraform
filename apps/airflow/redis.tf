resource "aws_elasticache_cluster" "redis" {
  cluster_id           = module.label.name
  tags                 = module.label.tags
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.5"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
}

resource "aws_security_group" "redis" {
  name        = "${module.label.name}-redis"
  tags        = module.label.tags
  description = "redis cluster security group"
  vpc_id      = module.shared.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.airflow.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elasticache_subnet_group" "redis" {
  name       = module.label.name
  subnet_ids = module.shared.private_subnets
}
output "cache_nodes" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}
