data "aws_route53_zone" "ccc" {
  name         = local.domain
  private_zone = false
}