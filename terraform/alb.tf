resource "aws_lb" "app_lb" {
  name               = "zsoftly-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.ecs_sg.id]
}
