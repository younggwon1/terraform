resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Default user data with nginx and CloudWatch Agent
  default_user_data = <<-EOF
  #cloud-config
  package_update: true
  packages:
    - nginx
    ${var.enable_cloudwatch_agent ? "- amazon-cloudwatch-agent" : ""}
  runcmd:
    - [ bash, -lc, 'if ! systemctl is-enabled nginx >/dev/null 2>&1; then systemctl enable nginx; fi' ]
    - [ bash, -lc, 'if ! systemctl is-active nginx >/dev/null 2>&1; then systemctl start nginx; fi' ]
    - [ bash, -lc, 'echo "hello from terraform" > /usr/share/nginx/html/index.html' ]
    ${var.enable_cloudwatch_agent ? <<-CWAGENT
    - [ bash, -lc, 'cat >/opt/aws/amazon-cloudwatch-agent/bin/config.json <<\"CONFIG\"
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_system",
          "cpu_usage_user"
        ],
        "totalcpu": true
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "$${!aws:AutoScalingGroupName}",
      "InstanceId": "$${!aws:InstanceId}",
      "InstanceType": "$${!aws:InstanceType}"
    }
  }
}
CONFIG' ]
    - [ bash, -lc, 'systemctl enable amazon-cloudwatch-agent' ]
    - [ bash, -lc, 'systemctl restart amazon-cloudwatch-agent' ]
    CWAGENT
: ""}
  EOF

# Use provided user_data if specified, otherwise use default
# Priority: user_data_base64 > user_data > default_user_data
user_data = var.user_data_base64 != "" ? var.user_data_base64 : (
  var.user_data != "" ? var.user_data : local.default_user_data
)

# Common tags
common_tags = merge(
  {
    Name = "${var.name_prefix}-instance"
    Team = var.team
  },
  var.extra_tags
)
}

data "aws_ami" "ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
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
    cpu_credits = var.cpu_credits != null ? var.cpu_credits : (
      startswith(var.instance_type, "t") ? "standard" : null
    )
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

  tags = local.common_tags
}

## IAM Role
resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-iam-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.common_tags
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
  name = "${var.name_prefix}-ec2-instance-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ec2.name

  tags = local.common_tags
}

## Security Group
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name_prefix}-ec2-security-group-${random_id.suffix.hex}"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP on 80 ports"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-ec2-sg"
    }
  )
}

resource "aws_security_group" "alb_security_group" {
  name        = "${var.name_prefix}-alb-security-group-${random_id.suffix.hex}"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-alb-sg"
    }
  )
}

## Application Load Balancer
resource "aws_lb" "ec2_alb" {
  name               = "${var.name_prefix}-ec2-alb-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups = [
    aws_security_group.alb_security_group.id,
  ]

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-ec2-alb"
    }
  )
}

resource "aws_lb_target_group" "ec2_alb_target_group_80" {
  name        = "${var.name_prefix}-target-group-80-${random_id.suffix.hex}"
  port        = var.health_check.port
  protocol    = var.health_check.protocol
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check.path
    port                = "traffic-port"
    protocol            = var.health_check.protocol
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    matcher             = var.health_check.matcher
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-target-group-80"
    }
  )
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
  ssl_policy        = var.ssl_policy
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
