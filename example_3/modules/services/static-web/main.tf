# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY STATIC WEBSITE ON AWS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
    required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
}


# ------------------------------------------------------------------------------
# DEPLOY STATIC WEBSITE AWS
# ------------------------------------------------------------------------------

locals {
    s3_origin_id = "s3-${var.dns_name}"
}

resource "aws_s3_bucket" "b" {
    bucket = var.dns_name
    
    website {
        index_document = "index.html"
        error_document = "index.html"
    }
    policy = <<POLICY
{
"Version": "2012-10-17",
"Id": "Policy1565527662639",
"Statement": [
    {
        "Sid": "Stmt1565527657378",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.dns_name}/*"
    }
]
}
  POLICY
}

resource "aws_s3_bucket_public_access_block" "b" {
    bucket = "${aws_s3_bucket.b.id}"

    block_public_policy = false
    block_public_acls = true
    ignore_public_acls = true
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  
  aliases = [var.dns_name]
  origin {
      domain_name = "${aws_s3_bucket.b.bucket_regional_domain_name}"
      origin_id = "${local.s3_origin_id}"
  }

  default_cache_behavior {
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = "${local.s3_origin_id}"
      viewer_protocol_policy = "redirect-to-https"
      min_ttl = 0
      default_ttl = 86400
      max_ttl = 31536000
      
      forwarded_values {
          query_string = false

          cookies {
              forward = "none"
          }
      }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"
  }

  restrictions {
      geo_restriction {
        restriction_type = "none"
      }
  }

  default_root_object = "index.html"
  price_class = "PriceClass_200"
  enabled = true
  is_ipv6_enabled = true
  
}

resource "aws_route53_record" "route" {
  zone_id = var.route53_zone
  name = var.dns_name
  type = "A"
  
  alias {
      name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
      zone_id = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
      evaluate_target_health = false
  }
}