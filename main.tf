

module "template_files"{
  source = "hashicorp/dir/template"
  base_dir = "${path.module}/website"
}


resource "aws_s3_bucket" "skr-bucket" {
    bucket = "skr-static-bucket"

    tags ={

        Name = "skr_s3_bucket"
    }
  
}

resource "aws_s3_bucket_ownership_controls" "skr_s3_ownership" {

    bucket = aws_s3_bucket.skr-bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
  
}

resource "aws_s3_bucket_public_access_block" "skr_s3_public_access" {
  
  bucket = aws_s3_bucket.skr-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

resource "aws_s3_bucket_policy" "skr_s3_policy" {
    bucket = aws_s3_bucket.skr-bucket.id
policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" = "Allow",
        "Principal" = "*",
        "Action" = "s3:GetObject",
        "Resource" = "${aws_s3_bucket.skr-bucket.arn}/*"
      }
    ]
  })
  
}

resource "aws_s3_bucket_website_configuration" "skr_hosting_website_configuration" {
  bucket = aws_s3_bucket.skr-bucket.id
  
  index_document {
    suffix = "static_website.html"
  }
}

resource "aws_s3_object" "skr_hosting_bucket_files" {
  bucket = aws_s3_bucket.skr-bucket.id

  for_each = module.template_files.files

  key = each.key
  content_type = each.value.content_type

  source = each.value.source_path
  content = each.value.content

  etag = each.value.digests.md5  
}