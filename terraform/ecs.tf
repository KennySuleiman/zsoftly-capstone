resource "aws_ecs_cluster" "this" {
  name = "zsoftly-cluster"
}

resource "aws_ecs_service" "app" {
  name            = "zsoftly-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "nginx-app"
    container_port   = 80
  }
}
