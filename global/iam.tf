# Osman Din - Engineer
resource "aws_iam_user" "osmandin" {
  name          = "osmandin"
  path          = "/"
  force_destroy = "true"
}

# Eric Hanson - Engineer
resource "aws_iam_user" "ehanson" {
  name          = "ehanson"
  path          = "/"
  force_destroy = "true"
}
