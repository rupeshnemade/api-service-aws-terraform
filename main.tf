terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

# Fetch VPC & Subnets related data from VPC network terraform state file
data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.region}/network/terraform.tfstate"
    region = "${var.region}"
  }
}

locals {
  tags               = "${map("Service","${var.service_name}","Terraform","true")}"
  subnets            = ["${slice(data.terraform_remote_state.network.private-subnets,0,min(length(data.terraform_remote_state.network.azs),length(data.terraform_remote_state.network.private-subnets)))}"]
  vpc_id             = "${data.terraform_remote_state.network.vpc-id}"
  cert_domain        = "${var.domain_name}"
  domain_name        = "${var.domain_name}"
}

module "ecs-roles" {
  source                     = "./ecs-roles"
  tags                       = "${local.tags}"
  service_name               = "${var.service_name}"
}

module "ecs-workers" {
  source                            = "./ecs-workers"
  apiService_ECR_URL                = "${var.apiService_ECR_URL}"
  workerService_ECR_URL             = "${var.workerService_ECR_URL}"
  image_tag                         = "${var.image_tag}"
  nats_image_name                   = "${var.nats_image_name}"
  ssh_key_name                      = "${var.ssh_key_name}"
  service_name                      = "${var.service_name}"
  instance_type                     = "${var.instance_type}"
  task_memory                       = "${var.task_memory}"
  task_cpu                          = "${var.task_cpu}"
  auto_scaling_max_size             = "${var.auto_scaling_max_size}"
  auto_scaling_desired_count        = "${var.auto_scaling_desired_count}"
  auto_scaling_min_size             = "${var.auto_scaling_min_size}"
  desired_count                     = "${var.desired_count}"
  ecs_role                          = "${module.ecs-roles.ecs-role-arn}"
  vpc_id                            = "${local.vpc_id}"
  subnets                           = "${local.subnets}"
  tags                              = "${local.tags}"
  region                            = "${var.region}"
  domain_name                       = "${var.domain_name}"
}