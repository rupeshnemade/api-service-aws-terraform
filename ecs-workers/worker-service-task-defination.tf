resource "aws_ecs_task_definition" "workerService" {
  family                = "${var.service_name}-workerService"
  task_role_arn         = "${var.ecs_role}"
  container_definitions = <<DEFINITION
[
  {
    "name": "workerService",
    "image": "${var.workerService_ECR_URL}:${var.image_tag}",
    "cpu": ${var.task_cpu},
    "memory": ${var.task_memory},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.workerService-ecs-task-log-group.name}",
        "awslogs-stream-prefix": "${var.service_name}-worker-service"
      }
    },
    "environment": [
      {
        "name": "NATS_URI",
         "value": "${var.service_name}-nats-service://${var.service_name}-nats-service:4222"
      },
      {
        "name": "PORT",
        "value": "8081"
      }
    ],
    "portMappings": [
      {
        "hostPort": 8081,
        "containerPort": 8081,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

data "aws_ecs_task_definition" "workerService" {
  task_definition = "${aws_ecs_task_definition.workerService.family}"
  depends_on      = [ "aws_ecs_task_definition.workerService" ]
}

resource "aws_cloudwatch_log_group" "workerService-ecs-task-log-group" {
  name = "workerService-task"
  tags = "${var.tags}"
}