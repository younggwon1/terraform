locals {
  user_data = <<-EOF
  #cloud-config
  package_update: true
  packages:
    - nginx
  runcmd:
    - [ bash, -lc, 'if ! systemctl is-enabled nginx >/dev/null 2>&1; then systemctl enable nginx; fi' ]
    - [ bash, -lc, 'if ! systemctl is-active nginx >/dev/null 2>&1; then systemctl start nginx; fi' ]
    - [ bash, -lc, 'echo "hello from terraform" > /usr/share/nginx/html/index.html' ]
  EOF
}

data "aws_ami" "ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ec2.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  user_data                   = local.user_data
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = false
  ebs_optimized               = true
  disable_api_termination     = true
  monitoring                  = true

  credit_specification {
    cpu_credits = startswith(var.instance_type, "t") ? "standard" : null
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_type           = var.ebs_volume_type
    volume_size           = var.ebs_volume_size
    iops                  = var.ebs_iops
    throughput            = var.ebs_throughput
    encrypted             = true
    delete_on_termination = false
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-instance"
      Team = var.team
    },
    var.extra_tags
  )
}

## IAM Role
resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

## Security Group
resource "aws_security_group" "ec2_security_group" {
  name   = "${var.name_prefix}-ec2-security-group"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP on 80 ports"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_security_group" {
  name   = "${var.name_prefix}-alb-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
    Team = var.team
  }
}

## Application Load Balancer
resource "aws_lb" "ec2_alb" {
  name               = "${var.name_prefix}-ec2-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups = [
    aws_security_group.alb_security_group.id,
  ]

  enable_deletion_protection = true

  tags = {
    Name = "${var.name_prefix}-ec2-alb"
    Team = var.team
  }
}

resource "aws_lb_target_group" "ec2_alb_target_group_80" {
  name        = "${var.name_prefix}-target-group-80"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.name_prefix}-target-group-80"
    Team = var.team
  }
}

resource "aws_lb_listener" "ec2_alb_listener_80" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ec2_alb_listener_443" {
  load_balancer_arn = aws_lb.ec2_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_alb_target_group_80.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.ec2_alb_target_group_80.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}
