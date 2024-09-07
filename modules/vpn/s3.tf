resource "aws_s3_bucket" "vpn_config_files" {
  bucket        = "stockzrs-vpn-config-files"
  force_destroy = true
  tags = {
    Name         = "stockzrs-vpn-config-files"
    CostType     = "AlwaysCreated"
    BackupPolicy = "n/a"
  }
}

resource "aws_s3_bucket_public_access_block" "vpn_config_files" {
  bucket                  = aws_s3_bucket.vpn_config_files.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpn_config_files" {
  bucket = aws_s3_bucket.vpn_config_files.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = ""
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_policy" "vpn_config_files" {
  bucket = aws_s3_bucket.vpn_config_files.id
  policy = data.aws_iam_policy_document.vpn_config_files.json
}

data "aws_iam_policy_document" "vpn_config_files" {
  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::stockzrs-vpn-config-files",
      "arn:aws:s3:::stockzrs-vpn-config-files/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
