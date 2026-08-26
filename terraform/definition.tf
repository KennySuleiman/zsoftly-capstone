resource "aws_ecs_task_definition" "app" {
  family                   = "zsoftly-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "nginx-app"
      image = "${aws_ecr_repository.app.repository_url}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}
