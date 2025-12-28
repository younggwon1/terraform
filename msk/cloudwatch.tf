resource "aws_cloudwatch_log_group" "msk_cloudwatch_log_group" {
  name              = "/aws-msk/${var.cluster_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.cloudwatch_logs_kms_key_id

  tags = {
    Name        = "${var.cluster_name}-cloudwatch-logs"
    Description = "CloudWatch Log Group for MSK cluster ${var.cluster_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
