## Security Group For Public ALB
resource "aws_security_group" "public-alb-sg" {
  name        = "public-alb-sg"
  description = "Allow 80, 443 Port inbound traffic and all outbound traffic"
  vpc_id      = local.vpc-id

  tags = {
    Name = "public-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-80" {
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-443" {
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow-all-traffic" {
  security_group_id = aws_security_group.public-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
