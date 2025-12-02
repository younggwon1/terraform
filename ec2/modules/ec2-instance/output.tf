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

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.ec2_alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.ec2_alb.arn
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.ec2_alb.zone_id
}

output "security_group_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2_security_group.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_security_group.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.ec2_alb_target_group_80.arn
}

output "target_group_id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.ec2_alb_target_group_80.id
}
