resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/inventory.tmpl",
    {
      zookeepers = aws_route53_record.zookeeper.*.fqdn,
      solrs      = aws_route53_record.solr.*.fqdn,
      app        = aws_route53_record.app_priv.*.fqdn
    }
  )
  filename = "ansible/inventories/${terraform.workspace}"
}
