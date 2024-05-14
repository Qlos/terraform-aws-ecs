# https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-connecting-services.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-connect.html
resource "aws_service_discovery_private_dns_namespace" "this" {
  for_each    = var.service_discovery_namespaces
  name        = each.key
  description = each.value
  vpc         = var.vpc_id
}
