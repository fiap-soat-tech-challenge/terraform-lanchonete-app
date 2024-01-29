resource "aws_security_group" "security_group_alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security Group ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_lb_target_group" "target_group_clientes" {
  name        = "${var.app_name}-target-group-clientes"
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_target_group" "target_group_pedidos" {
  name        = "${var.app_name}-target-group-pedidos"
  port        = 3002
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_target_group" "target_group_pagamentos" {
  name        = "${var.app_name}-target-group-pagamentos"
  port        = 3003
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_target_group" "target_group_producao" {
  name        = "${var.app_name}-target-group-producao"
  port        = 3004
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = true
  security_groups    = [aws_security_group.security_group_alb.id]
  load_balancer_type = "application"

  subnets = aws_subnet.private_subnet.*.id

  tags = local.tags
}

resource "aws_lb_listener" "listener_alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code  = "200"
      message_body = "<html><body><h1>Hello, World!</h1></body></html>"
    }
  }
}

resource "aws_lb_listener_rule" "clientes_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clientes.arn
  }

  condition {
    path_pattern {
      values = ["/api/clientes/*"]
    }
  }
}

resource "aws_lb_listener_rule" "pedidos_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pedidos.arn
  }

  condition {
    path_pattern {
      values = ["/api/pedidos/*"]
    }
  }
}

resource "aws_lb_listener_rule" "pagamentos_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pagamentos.arn
  }

  condition {
    path_pattern {
      values = ["/api/pagamentos/*"]
    }
  }
}

resource "aws_lb_listener_rule" "producao_rule" {
  listener_arn = aws_lb_listener.listener_alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.producao.arn
  }

  condition {
    path_pattern {
      values = ["/api/producao/*"]
    }
  }
}