locals {
  domain_name = var.env == "live" ? var.domain : "${var.env}-${var.domain}"
}

resource "aws_acm_certificate" "domain" {
  provider          = aws.us-east-1
  domain_name       = local.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

data "aws_route53_zone" "domain" {
  private_zone = false
  zone_id      = var.zone_id
}
