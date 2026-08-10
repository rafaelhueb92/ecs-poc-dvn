resource "aws_acm_certificate" "this" {
  count            = var.use_certificate ? 1 : 0
  domain_name       = "*.dvn.com" # Replace with your domain name
  validation_method = "DNS"

  tags = {
    Name = "dvn-acm-certificate"
  }
}