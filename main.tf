
# locals
locals {
  name     = "cloudcodecoffee"
  domain   = "cloudcodecoffee.com"
}

# ----- S3 -----

# create the bucket
resource "aws_s3_bucket" "ccc" {
  bucket = local.domain

  tags = {
    Name        = local.name
  }
}

# create the ACL + configure settings so bucket is public
resource "aws_s3_bucket_ownership_controls" "ccc" {
  bucket = aws_s3_bucket.ccc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "ccc" {
  bucket = aws_s3_bucket.ccc.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "ccc" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ccc,
    aws_s3_bucket_public_access_block.ccc,
  ]

  bucket = aws_s3_bucket.ccc.id
  acl    = "public-read"
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
      "Effect": "Allow",
	  "Principal": "*",
      "Action": [ "s3:GetObject" ],
      "Resource": [
        "${aws_s3_bucket.ccc.arn}/*"
      ]
    }
  ]
}
EOF
}

# ----- Route53 -----

# create the hosted zone in Route53
resource "aws_route53_zone" "apex" {
  name = local.domain
}

# create the alias record (will need to eventually point this to CloudFront)
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.apex.zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.apex.zone_id
  name    = join(".", ["www", local.domain])
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# ----- CloudFront -----

