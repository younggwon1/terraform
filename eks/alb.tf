resource "aws_lb" "public-alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    aws_security_group.public-alb-sg.id,
  ]
  subnets            = local.public-subnet-ids
  enable_deletion_protection = true
  
  tags = {
    Name = "public-alb"
  }
}

resource "aws_lb_target_group" "public-alb-tg" {
  name     = "public-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc-id
}

resource "aws_lb_listener" "public-alb-listener-80" {
  load_balancer_arn = aws_lb.public-alb.arn
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

resource "aws_lb_listener" "public-alb-listener-443" {
  load_balancer_arn = aws_lb.public-alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = "temp"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-alb-tg.arn
  }
}
