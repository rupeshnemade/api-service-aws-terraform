# API service
resource "aws_ecs_service" "api_service" {
  name            = "${var.service_name}-api-service"
  task_definition = "${aws_ecs_task_definition.apiService.family}:${max("${aws_ecs_task_definition.apiService-worker.revision}", "${data.aws_ecs_task_definition.apiService.revision}")}"
  desired_count   = "${var.desired_count}"
  cluster         = "${aws_ecs_cluster.hotelService_ecs_cluster.id}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.apiService_alb_target.arn}"
    container_name = "apiService"
    container_port = 8080
  }

  depends_on = [
    "aws_autoscaling_group.ecs-autoscaling-group",
    "aws_iam_role.ecs-instance-role",
    "aws_ecs_task_definition.apiService",
    "aws_alb_target_group.apiService_alb_target",
  ]
}

# Worker service
resource "aws_ecs_service" "worker_service" {
  name            = "${var.service_name}-worker-service"
  task_definition = "${aws_ecs_task_definition.workerService.family}:${max("${aws_ecs_task_definition.authService-worker.revision}", "${data.aws_ecs_task_definition.authService-worker.revision}")}"
  desired_count   = "${var.desired_count}"
  cluster         = "${aws_ecs_cluster.hotelService_ecs_cluster.id}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.workerService_alb_target.arn}"
    container_name = "workerService"
    container_port = 8081
  }

  depends_on = [
    "aws_autoscaling_group.ecs-autoscaling-group",
    "aws_iam_role.ecs-instance-role",
    "aws_ecs_task_definition.workerService",
    "aws_alb_target_group.workerService_alb_target",
  ]
}

# NATS service
resource "aws_ecs_service" "nats_service" {
  name            = "${var.service_name}-nats-service"
  task_definition = "${aws_ecs_task_definition.natsService.family}:${max("${aws_ecs_task_definition.natsService.revision}", "${data.aws_ecs_task_definition.natsService.revision}")}"
  desired_count   = "${var.desired_count}"
  cluster         = "${aws_ecs_cluster.hotelService_ecs_cluster.id}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.natsService_alb_target.arn}"
    container_name = "natsService"
    container_port = 8222
  }

  depends_on = [
    "aws_autoscaling_group.ecs-autoscaling-group",
    "aws_iam_role.ecs-instance-role",
    "aws_ecs_task_definition.natsService",
    "aws_alb_target_group.natsService_alb_target",
  ]
}