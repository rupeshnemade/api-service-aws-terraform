variable "region" {}

variable "domain_name" {
  description = "Route53 domain name for alias"
}

variable "service_name" {
  description = "Name of application service"
  default = "Hotel"
}

variable "image_tag" {
  description = "Docker image tag to use in container def"
}

variable "nats_image_name" {
  description = "NATS stream image name"
}

variable "apiService_ECR_URL" {
  description = "URL of ECR Repository for API service"
  default = "960885402552.dkr.ecr.us-east-1.amazonaws.com/hotel/apiervice"
}

variable "workerService_ECR_URL" {
  description = "URL of ECR Repository for Worker service"
  default = "960885402552.dkr.ecr.us-east-1.amazonaws.com/hotel/workerservice"
}

variable "instance_type" {}

variable "ssh_key_name" {
  description = "Name of the key-pair to be genarted for ECS instance"
  default = "hotel-ecs-key"
}

variable "remote_state_bucket" {}

variable "task_memory" {
  default = 2048
}

variable "task_cpu" {
  default = 512
}

variable "desired_count" {
  default = 1
}

variable "auto_scaling_min_size" {
  default = 1
}

variable "auto_scaling_max_size" {
  default = 2
}

variable "auto_scaling_desired_count" {
  default = 1
}
