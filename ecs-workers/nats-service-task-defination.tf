resource "aws_ecs_task_definition" "natsService" {
  family                = "${var.service_name}-natsService"
  task_role_arn         = "${var.ecs_role}"
  container_definitions = <<DEFINITION
[
  {
    "name": "natsService",
    "image": "${var.nats_image_name}",
    "cpu": ${var.task_cpu},
    "memory": ${var.task_memory},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.natsService-ecs-task-log-group.name}",
        "awslogs-stream-prefix": "${var.service_name}-nats-service"
      }
    },
    "portMappings": [
      {
        "hostPort": 8222,
        "containerPort": 8222,
        "protocol": "tcp"
      },
      {
          "containerPort": 4222
      }
    ]
  }
]
DEFINITION
}

data "aws_ecs_task_definition" "natsService" {
  task_definition = "${aws_ecs_task_definition.natsService.family}"
  depends_on      = [ "aws_ecs_task_definition.natsService" ]
}

resource "aws_cloudwatch_log_group" "natsService-ecs-task-log-group" {
  name = "natsService-task"
  tags = "${var.tags}"
}