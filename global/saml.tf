resource "aws_iam_saml_provider" "mit" {
  name                   = "IdP"
  saml_metadata_document = "${file("files/MIT-IdP-metadata.xml")}"
}
