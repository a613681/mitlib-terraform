# Create zone.
resource "aws_route53_zone" "simile" {
  name = "simile-widgets.org"

  tags = {
    terraform   = "true"
    environment = "global"
    Name        = "simile-widgets.org"
  }
}

# Set up name server records.
resource "aws_route53_record" "simile-ns" {
  zone_id = aws_route53_zone.simile.zone_id
  name    = aws_route53_zone.simile.name
  type    = "NS"
  ttl     = 86400

  records = [
    aws_route53_zone.simile.name_servers.0,
    aws_route53_zone.simile.name_servers.1,
    aws_route53_zone.simile.name_servers.2,
    aws_route53_zone.simile.name_servers.3,
  ]
}

# Set up SOA.
resource "aws_route53_record" "simile-soa" {
  zone_id = aws_route53_zone.simile.id
  name    = aws_route53_zone.simile.name
  type    = "SOA"
  ttl     = 900

  records = [
    "${aws_route53_zone.simile.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

# Create DNS entries for websites.
resource "aws_route53_record" "simile-api" {
  zone_id = aws_route53_zone.simile.id
  name    = "api.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = 300
  records = var.r53_api_value
}

resource "aws_route53_record" "simile-service" {
  zone_id = aws_route53_zone.simile.id
  name    = "service.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = 300
  records = var.r53_service_value
}

resource "aws_route53_record" "simile-trunk" {
  zone_id = aws_route53_zone.simile.id
  name    = "trunk.${aws_route53_zone.simile.name}"
  type    = "A"
  ttl     = 300
  records = var.r53_trunk_value
}

resource "aws_route53_record" "simile-web" {
  zone_id = aws_route53_zone.simile.id
  name    = aws_route53_zone.simile.name
  type    = "A"
  ttl     = 300
  records = var.r53_web_value
}
