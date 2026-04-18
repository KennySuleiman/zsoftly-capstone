resource "aws_lb_target_group" "tg" {
  name        = "zsoftly-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}
