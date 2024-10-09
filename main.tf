provider "aws" {
  region = "us-west-2"  # Specify your preferred region
}

resource "aws_s3_bucket" "log_archiver_bucket" {
  bucket = "log-archiver-bucket"  

  tags = {
    Name        = "Log Archiver Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "log_archiver_ownership" {
  bucket = aws_s3_bucket.log_archiver_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_archiver_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.log_archiver_ownership]

  bucket = aws_s3_bucket.log_archiver_bucket.id
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.log_archiver_bucket.bucket
}
