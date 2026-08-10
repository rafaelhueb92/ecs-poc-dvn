resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.use_certificate ? 443 : 80
  protocol          = var.use_certificate ? "HTTPS" : "HTTP"

  certificate_arn =  var.use_certificate ? aws_acm_certificate.this[0].arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}