#Create the Public mitlib.net Zone
resource "aws_route53_zone" "main_pub" {
  name    = "mitlib.net"
  comment = "Public DNS Zone"
}

/*
#Create the Private mitlib.net Zone
resource "aws_route53_zone" "main_priv" {
  name    = "mitlib.net"
  comment = "Internal DNS"

  vpc {
    vpc_id = "${aws_vpc.example.id}"
  }
}
*/

