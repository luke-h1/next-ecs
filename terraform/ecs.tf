


resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-${var.env}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.project_name}-${var.env}",
      "image": "${aws_ecr_repository.app_ecr_repo.repository_url}:${var.docker_image_tag}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.app_log_group.name}",
          "awslogs-region": "eu-west-2",
          "awslogs-stream-prefix": "${var.project_name}"
        }
      },
    "memory": ${tonumber(var.memory)},     
    "cpu": ${var.cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn
}

resource "aws_ecs_service" "app_ecs" {
  name            = "${var.project_name}-${var.env}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.task_count
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.application_subnet_a.id}", "${aws_default_subnet.application_subnet_b.id}", "${aws_default_subnet.application_subnet_c.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.app_lb_security_group.id}"]
  }
}

