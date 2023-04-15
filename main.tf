# local variables for frequently referenced values
locals {
  name   = "cloudcodecoffee"
  domain = "cloudcodecoffee.com"
}

# ----- S3 -----

# create the bucket
resource "aws_s3_bucket" "ccc" {
  bucket = local.domain
}

# create the ACL + configure settings so bucket is public
resource "aws_s3_bucket_ownership_controls" "ccc" {
  bucket = aws_s3_bucket.ccc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# because we're fronting with CloudFront, we can keep public access to S3 bucket blocked
resource "aws_s3_bucket_public_access_block" "ccc" {
  bucket = aws_s3_bucket.ccc.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# since using CloudFront, can keep ACL private. Otherwise this would have to be "public-read"
resource "aws_s3_bucket_acl" "ccc" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ccc,
    aws_s3_bucket_public_access_block.ccc,
  ]

  bucket = aws_s3_bucket.ccc.id
  acl    = "private"
}

# set bucket to be static website
resource "aws_s3_bucket_website_configuration" "ccc" {
  bucket = aws_s3_bucket.ccc.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# configure bucket policy to allow public read
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.ccc.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OAC",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.ccc.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${aws_cloudfront_distribution.ccc.arn}" 
                }
            }           
        }
    ]
}
EOF
}

# ----- Route53 -----

# create the hosted zone in Route53
resource "aws_route53_zone" "ccc" {
  name = local.domain
}

# create the alias record (will need to eventually point this to CloudFront)
resource "aws_route53_record" "ccc" {
  zone_id = aws_route53_zone.ccc.zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ccc.domain_name
    zone_id                = aws_cloudfront_distribution.ccc.hosted_zone_id
    evaluate_target_health = false
  }
}

# create alias record for www
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.ccc.zone_id
  name    = join(".", ["*", local.domain])
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ccc.domain_name
    zone_id                = aws_cloudfront_distribution.ccc.hosted_zone_id
    evaluate_target_health = false
  }
}


# ----- CloudFront -----
# using CloudFront to not only cache static content but to provide HTTPS access to S3 bucket

# create Origin Access Control (OAC) so that S3 bucket only allows traffic from this CloudFront distribution
resource "aws_cloudfront_origin_access_control" "cf_oac" {
  name                              = local.name
  description                       = "OAC policy for S3 static site ${local.domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# create the CloudFront distribution
resource "aws_cloudfront_distribution" "ccc" {
  origin {
    domain_name              = aws_s3_bucket.ccc.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_oac.id
    origin_id                = local.name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases = [local.domain, "*.${local.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  # Add in error.html for common 4xx errors
  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
  }

  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 403
    response_code         = 403
    response_page_path    = "/error.html"
  }
  # this is the cheapest option which includes NA and EU regions only
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate_validation.ccc.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }

}
# ----- ACM -----
# create certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

# this will create the appropriate DNS record(s) for validation
resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id = aws_route53_zone.ccc.zone_id
}

resource "aws_acm_certificate_validation" "ccc" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}
