resource "aws_ecs_task_definition" "apiService" {
  family                = "${var.service_name}-apiService"
  task_role_arn         = "${var.ecs_role}"
  container_definitions = <<DEFINITION
[
  {
    "name": "apiService",
    "image": "${var.apiService_ECR_URL}:${var.image_tag}",
    "cpu": ${var.task_cpu},
    "memory": ${var.task_memory},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.apiService-ecs-task-log-group.name}",
        "awslogs-stream-prefix": "${var.service_name}-api-service"
      }
    },
    "environment": [
      {
        "name": "NATS_URI",
        "value": "${var.service_name}-nats-service://${var.service_name}-nats-service:4222"
      },
      {
        "name": "PORT",
        "value": "8080"
      }
    ],
    "portMappings": [
      {
        "hostPort": 8080,
        "containerPort": 8080,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

data "aws_ecs_task_definition" "apiService" {
  task_definition = "${aws_ecs_task_definition.apiService.family}"
  depends_on      = [ "aws_ecs_task_definition.apiService" ]
}

resource "aws_cloudwatch_log_group" "apiService-ecs-task-log-group" {
  name = "apiService-task"
  tags = "${var.tags}"
}