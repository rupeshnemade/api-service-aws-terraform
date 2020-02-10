variable "region" {}
variable "domain_name" {}
variable "service_name" {}

variable "tags" {
  type = "map"
}

# Network variable
variable "subnets" {
  type = "list"
}
variable "ssh_key_name" {}
variable "auto_scaling_min_size" {}
variable "auto_scaling_max_size" {}
variable "auto_scaling_desired_count" {}
variable "instance_type" {}

// ECS variables
variable "apiService_ECR_URL" {}
variable "workerService_ECR_URL" {}
variable "image_tag" {}
variable "nats_image_name" {}
variable "task_cpu" {}
variable "task_memory" {}
variable "desired_count" {}
variable "ecs_role" {}
variable "vpc_id" {}


