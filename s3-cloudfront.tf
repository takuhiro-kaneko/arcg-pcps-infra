# Definition of cloudfront 
resource "aws_s3_bucket" "s3-kkc-d2pf-02-cloudfront" {
  bucket = "s3-kkc-d2pf-02-cloudfront"  
  
  tags = {
    Name        = "ArcGIS PCPS Bucket Vol 02"
  }
}

resource "aws_s3_bucket_acl" "s3-kkc-d2pf-02-cloudfront" {
  bucket = aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket" {
    bucket = aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.id
    policy = data.aws_iam_policy_document.static-www.json
}

data "aws_iam_policy_document" "static-www" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
        type = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
        "s3:GetObject"
    ]

    resources = [
        aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.arn,
        "${aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.arn}/*",
    ]

  }
}

resource "aws_cloudfront_distribution" "E1TZTLU92NB9YS" {
    origin {
        domain_name = "${aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.bucket_regional_domain_name}"
        origin_id = aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.id
        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.E1TZTLU92NB9YS.cloudfront_access_identity_path
        }
    }

    enabled =  true

    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods = [ "GET", "HEAD" ]
        cached_methods = [ "GET", "HEAD" ]
        target_origin_id = aws_s3_bucket.s3-kkc-d2pf-02-cloudfront.id
        
        forwarded_values {
            query_string = false

            cookies {
              forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
      geo_restriction {
          restriction_type = "whitelist"
          locations = [ "JP" ]
      }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_cloudfront_origin_access_identity" "E1TZTLU92NB9YS" {}

