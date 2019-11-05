# For now, use this to define any extra AWS resources needed by workflow tasks
# that don't fit anywhere else. We need a better way to manage this.


module "oaiharvester_ecr" {
  source = "github.com/mitlibraries/tf-mod-ecr?ref=0.12"
  name   = "oaiharvester"
}
