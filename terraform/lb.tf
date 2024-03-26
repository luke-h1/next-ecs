resource "aws_default_vpc" "default_vpc" {
}
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "${var.project_name}-${var.env}"
  tags = {
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project_name}-${var.env}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_default_subnet" "application_subnet_a" {
  availability_zone = "eu-west-2a"
}

resource "aws_default_subnet" "application_subnet_b" {
  availability_zone = "eu-west-2b"
}

resource "aws_default_subnet" "application_subnet_c" {
  availability_zone = "eu-west-2c"
}

resource "aws_alb" "app_lb" {
  name               = "${var.project_name}-lb-${var.env}"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.application_subnet_a.id}",
    "${aws_default_subnet.application_subnet_b.id}",
    "${aws_default_subnet.application_subnet_c.id}"
  ]
  security_groups = ["${aws_security_group.app_lb_security_group.id}"]
}

resource "aws_security_group" "app_lb_security_group" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "app_tg" {
  name                 = "${var.project_name}-tg-${var.env}"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_default_vpc.default_vpc.id
  deregistration_delay = 300
  health_check {
    matcher             = "200,301,302"
    path                = "/api/healthcheck"
    interval            = 5
    timeout             = 30
    unhealthy_threshold = 3
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 3600
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_alb.app_lb.arn
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

# HTTPS support
resource "aws_lb_listener" "web_https" {
  load_balancer_arn = aws_alb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.domain.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


resource "aws_security_group" "app_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.app_lb_security_group.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app_lb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
