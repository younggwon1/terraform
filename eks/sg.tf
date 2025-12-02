# 특정 Security Group을 수동으로 정의하거나, 기본 동작을 오버라이드하고 싶다면 security group을 생성한 후 ingress annotation에 추가합니다.
# alb.ingress.kubernetes.io/security-groups: <security-group-id-1>,<security-group-id-2>

## Security Group For Public ALB
resource "aws_security_group" "public-alb-sg" {
  name        = "public-alb-sg"
  description = "Allow 80, 443 Port inbound traffic and all outbound traffic"
  vpc_id      = local.vpc_id

  tags = {
    Name = "public-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-80" {
  for_each          = toset(var.alb_allowed_cidrs)
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = each.value
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-443" {
  for_each          = toset(var.alb_allowed_cidrs)
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow-all-traffic" {
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
