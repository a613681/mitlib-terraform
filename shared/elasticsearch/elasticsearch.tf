module "elasticsearch" {
  source = "github.com/mitlibraries/tf-mod-aws-elasticsearch?ref=0.12"
  name   = "elasticsearch"

  instance_count                     = var.instance_count
  instance_type                      = var.instance_type
  es_zone_awareness                  = var.es_zone_awareness
  ebs_volume_size                    = var.ebs_volume_size
  es_version                         = var.es_version
  encrypt_at_rest                    = "false"
  log_publishing_application_enabled = var.log_publishing_application_enabled
  log_publishing_index_enabled       = var.log_publishing_index_enabled
  log_publishing_search_enabled      = var.log_publishing_search_enabled

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

