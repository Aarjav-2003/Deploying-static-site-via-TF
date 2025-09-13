terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.13.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  region="ap-south-1"
}

resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "myweberjav" {
    bucket = "${random_id.rand_id.hex}-myweberjav"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.myweberjav.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "myweberjav" {
    bucket = aws_s3_bucket.myweberjav.id
    policy = jsonencode(
        {
            Version = "2012-10-17",
            Statement = [
                {
                    Sid= "PublicReadGetObject",
                    Effect= "Allow",
                    Principal= "*",
                    Action="s3:GetObject",
                    Resource="arn:aws:s3:::${aws_s3_bucket.myweberjav.id}/*"
                }
            ]
        }
    )
}

resource "aws_s3_bucket_website_configuration" "myweberjav" {
  bucket = aws_s3_bucket.myweberjav.id 

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.myweberjav.bucket
    source="./index.html"
    key="index.html"
    content_type = "text/html"
}

output "name" {
  value=aws_s3_bucket_website_configuration.myweberjav.website_endpoint
}