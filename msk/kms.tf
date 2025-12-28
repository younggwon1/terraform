resource "aws_kms_key" "msk_kms_key" {
  description             = "KMS key for MSK cluster ${var.cluster_name} encryption"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  tags = {
    Name        = "${var.cluster_name}-kms-key"
    Description = "KMS key for MSK cluster encryption"
  }

  # IMPORTANT: Terraform lifecycle blocks do not support variables or any expressions.
  # They only accept literal boolean values (true or false).
  # 
  # To control prevent_destroy behavior:
  # - For production: Set prevent_destroy = true (default, protects against accidental deletion)
  # - For non-production: Set prevent_destroy = false or remove this lifecycle block
  # 
  # To delete a protected resource, you must:
  # 1. Manually edit this file and set prevent_destroy = false
  # 2. Run terraform apply to update the lifecycle
  # 3. Run terraform destroy to delete the resource
  #
  # Current setting: prevent_destroy = true (production-safe default)
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key_policy" "msk_kms_key_policy" {
  key_id = aws_kms_key.msk_kms_key.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "${aws_kms_key.msk_kms_key.arn}"
      },
      {
        Sid    = "Allow access through Kafka for all principals in the account that are authorized to use Kafka"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:DescribeKey"
        ],
        Resource = "${aws_kms_key.msk_kms_key.arn}"
        Condition = {
          StringEquals = {
            "kms:ViaService"    = "kafka.${data.aws_region.current.id}.amazonaws.com"
            "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      {
        Sid    = "Allow use of the key for MSK service"
        Effect = "Allow"
        Principal = {
          Service = "kafka.${data.aws_region.current.id}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource = "${aws_kms_key.msk_kms_key.arn}"
        Condition = {
          StringEquals = {
            "kms:ViaService"    = "kafka.${data.aws_region.current.id}.amazonaws.com"
            "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "msk_kms_key_alias" {
  name          = "alias/msk-kms-key"
  target_key_id = aws_kms_key.msk_kms_key.id
}
