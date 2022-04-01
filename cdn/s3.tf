resource "aws_s3_bucket" "vrs_cdn_source_bucket" {
  bucket = local.primary_domain

  tags = { "Name" : local.primary_domain }
}

resource "aws_cloudfront_origin_access_identity" "vrs_cdn_source_bucket" {
  comment = local.primary_domain
}

data "aws_iam_policy_document" "vrs_cdn_source_bucket_policy" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "${aws_s3_bucket.vrs_cdn_source_bucket.arn}/*",
      aws_s3_bucket.vrs_cdn_source_bucket.arn
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.vrs_cdn_source_bucket.iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "vrs_cdn_source_bucket" {
  bucket = aws_s3_bucket.vrs_cdn_source_bucket.id
  policy = data.aws_iam_policy_document.vrs_cdn_source_bucket_policy.json
}

locals {
  current_time = timestamp()
  three_months = timeadd(local.current_time, "2160h")
}

module "template_files" {
  source = "hashicorp/dir/template"
  base_dir = "./s3_bucket"
  template_vars = {
    # Pass in any values that you wish to use in your templates.
    workspace = terraform.workspace
    securitytxt_url = "https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt"
    policy_url = "https://${local.primary_domain}"
    contact_url = "https://${local.primary_domain}/submit"
    ack_url = "https://${local.primary_domain}/acknowledgements"
    last_updated = local.current_time
    expiry_date = local.three_months
    acknowledgements = local.acknowledgements
    footerlinks = local.footerlinks
  }
}

resource "aws_s3_object" "s3_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.vrs_cdn_source_bucket.id
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}
