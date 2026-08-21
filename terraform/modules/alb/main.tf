# Security Groups, Target Groups, ALB, rules, listener

# Security Group
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security Group for the public ALB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  description       = "HTTP from internet"
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allows Outbound traffic"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Loab Balancer
resource "aws_alb" "main" {
  name                       = "${var.name}-alb"
  load_balancer_type         = "application"
  internal                   = "false"
  subnets                    = var.public-subnets
  security_groups            = [aws_security_group.alb.id]
  enable_deletion_protection = false
  drop_invalid_header_fields = true
}

# Target Groups
resource "aws_lb_target_group" "backend" {
  name             = "${var.name}-backend"
  vpc_id           = var.vpc_id
  target_type      = "instance"
  protocol         = "HTTP"
  port             = var.backend_port
  protocol_version = "HTTP1"
  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  ## I want to test statelessness so no sticky for now
  # stickiness {
  #   enabled         = true
  #   type            = "lb_cookie"
  #   cookie_duration = 3600
  # }
  deregistration_delay = 30
}

# Listeners and Rules
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
