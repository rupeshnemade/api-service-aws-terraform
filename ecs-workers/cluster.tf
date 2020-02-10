resource "aws_ecs_cluster" "hotelService_ecs_cluster" {
  name = "${var.service_name}-cluster"
}
