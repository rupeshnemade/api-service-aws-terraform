
resource "aws_security_group" "alb_sg" {
  name        = "${var.service_name}-alb"
  description = "Allow HTTPS from Anywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags   = "${var.tags}"
}

# Api service ALB & TargetGroup
resource "aws_alb" "apiService_alb" {
  name = "${var.stage}-apiService-ALB"
  internal = true

  security_groups = [
    "${aws_security_group.alb_sg.id}"
  ]

  subnets = ["${var.subnets}"]
  tags   = "${var.tags}"
}

resource "aws_alb_target_group" "apiService_alb_target" {
  name = "${var.stage}-apiService-tg"
  protocol = "HTTP"
  port = "8080"
  vpc_id = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    path = "/"
  }

  depends_on = ["aws_alb.apiService_alb"]
}

# Worker service ALB & TargetGroup
resource "aws_alb" "workerService_alb" {
  name = "${var.stage}-workerService-ALB"
  internal = true

  security_groups = [
    "${aws_security_group.alb_sg.id}"
  ]

  subnets = ["${var.subnets}"]
  tags   = "${var.tags}"
}

resource "aws_alb_target_group" "workerService_alb_target" {
  name = "${var.stage}-workerService-tg"
  protocol = "HTTP"
  port = "8081"
  vpc_id = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    path = "/"
  }

  depends_on = ["aws_alb.workerService_alb"]
}

# NATS service ALB & TargetGroup
resource "aws_alb" "natsService_alb" {
  name = "${var.stage}-natsService-ALB"
  internal = true

  security_groups = [
    "${aws_security_group.alb_sg.id}"
  ]

  subnets = ["${var.subnets}"]
  tags   = "${var.tags}"
}

resource "aws_alb_target_group" "natsService_alb_target" {
  name = "${var.stage}-natsService-tg"
  protocol = "HTTP"
  port = "8222"
  vpc_id = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    path = "/"
  }

  depends_on = ["aws_alb.authService_alb"]
}

# Fetch domain certificate for HTTPS calls
data "aws_acm_certificate" "cert" {
  domain = "*.${var.domain_name}"
  types = ["AMAZON_ISSUED"]
}

# API service ALB listner
resource "aws_alb_listener" "apiService_listner" {
  load_balancer_arn = "${aws_alb.apiService_alb.arn}"
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2015-05"
  certificate_arn     = "${data.aws_acm_certificate.cert.arn}"


  default_action {
    target_group_arn = "${aws_alb_target_group.apiService_alb_target.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.apiService_alb_target"]
}

# Worker service ALB listner
resource "aws_alb_listener" "workerService_listner" {
  load_balancer_arn = "${aws_alb.workerService_alb.arn}"
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2015-05"
  certificate_arn     = "${data.aws_acm_certificate.cert.arn}"


  default_action {
    target_group_arn = "${aws_alb_target_group.workerService_alb_target.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.workerService_alb_target"]
}

# NATS service ALB listner
resource "aws_alb_listener" "natsService_listner" {
  load_balancer_arn = "${aws_alb.apiService_alb.arn}"
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2015-05"
  certificate_arn     = "${data.aws_acm_certificate.cert.arn}"


  default_action {
    target_group_arn = "${aws_alb_target_group.apiService_alb_target.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.apiService_alb_target"]
}

# Register API service ALB in Route 53 for external API calls.
data "aws_route53_zone" "hotel-service-zone" {
  name         = "${var.domain_name}"
}

resource "aws_route53_record" "apiService_endpoint" {
  zone_id = "${data.aws_route53_zone.hotel-service-zone.id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.apiService_alb.dns_name}"
    zone_id                = "${aws_alb.apiService_alb.zone_id}"
    evaluate_target_health = true
  }
}