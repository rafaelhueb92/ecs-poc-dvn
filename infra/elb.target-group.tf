resource "aws_lb_target_group" "this" {
  name        = "dvn-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  #health_check {
  #  path                = "/"
  #  interval            = 30
  #  timeout             = 5
  #  healthy_threshold   = 2
  #  unhealthy_threshold = 2
  #  matcher             = "200-299"
  #}
}