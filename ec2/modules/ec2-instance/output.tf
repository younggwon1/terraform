output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.ec2.arn
}

output "iam_role_name" {
  description = "The name of the IAM role attached to the instance"
  value       = aws_iam_role.ec2.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role attached to the instance"
  value       = aws_iam_role.ec2.arn
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}
