resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/inventory.tmpl",
    {
      app = aws_route53_record.app_priv.*.fqdn
    }
  )
  filename = "ansible/inventories/${terraform.workspace}"
}
