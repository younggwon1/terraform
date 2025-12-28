## MSK Cluster
output "msk_cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = aws_msk_cluster.msk.arn
}

output "msk_cluster_name" {
  description = "Name of the MSK cluster"
  value       = aws_msk_cluster.msk.cluster_name
}

output "msk_cluster_id" {
  description = "ID of the MSK cluster"
  value       = aws_msk_cluster.msk.id
}

output "msk_cluster_current_version" {
  description = "Current version of the MSK cluster"
  value       = aws_msk_cluster.msk.current_version
}

output "msk_cluster_zookeeper_connect_string" {
  description = "Zookeeper connection string"
  value       = aws_msk_cluster.msk.zookeeper_connect_string
  sensitive   = true
}

output "msk_cluster_bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers
  sensitive   = true
}

output "msk_cluster_bootstrap_brokers_sasl_iam" {
  description = "SASL/IAM authentication connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers_sasl_iam
  sensitive   = true
}

output "msk_cluster_bootstrap_brokers_tls" {
  description = "TLS encrypted connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers_tls
  sensitive   = true
}

output "msk_cluster_bootstrap_brokers_sasl_scram" {
  description = "SASL/SCRAM authentication connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers_sasl_scram
  sensitive   = true
}

## Security Group
output "msk_security_group_id" {
  description = "ID of the MSK security group"
  value       = aws_security_group.msk_security_group.id
}

## KMS
output "msk_kms_key_id" {
  description = "ID of the KMS key used for MSK encryption"
  value       = aws_kms_key.msk_kms_key.id
}

output "msk_kms_key_arn" {
  description = "ARN of the KMS key used for MSK encryption"
  value       = aws_kms_key.msk_kms_key.arn
}

output "msk_kms_key_alias" {
  description = "Alias of the KMS key used for MSK encryption"
  value       = aws_kms_alias.msk_kms_key_alias.name
}

## CloudWatch Logs
output "msk_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for MSK"
  value       = aws_cloudwatch_log_group.msk_cloudwatch_log_group.name
}

output "msk_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for MSK"
  value       = aws_cloudwatch_log_group.msk_cloudwatch_log_group.arn
}

## MSK Configuration
output "msk_configuration_arn" {
  description = "ARN of the MSK configuration"
  value       = aws_msk_configuration.msk_configuration.arn
}

output "msk_configuration_latest_revision" {
  description = "Latest revision of the MSK configuration"
  value       = aws_msk_configuration.msk_configuration.latest_revision
}

