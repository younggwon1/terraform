output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.alb_certificate.arn
}
