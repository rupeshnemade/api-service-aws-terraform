resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                        = "${var.service_name}-ecs-autoscaling-group"
  max_size                    = "${var.auto_scaling_max_size}"
  min_size                    = "${var.auto_scaling_min_size}"
  desired_capacity            = "${var.auto_scaling_desired_count}"
  vpc_zone_identifier         = ["${var.subnets}"]
  launch_configuration        = "${aws_launch_configuration.launch.name}"
  enabled_metrics             = ["GroupStandbyInstances",
                                 "GroupTotalInstances",
                                 "GroupPendingInstances",
                                 "GroupTerminatingInstances",
                                 "GroupDesiredCapacity",
                                 "GroupInServiceInstances",
                                 "GroupMinSize",
                                 "GroupMaxSize"]

  tags = [
    {
      key = "Name"
      value = "${var.service_name}ECSInstance"
      propagate_at_launch = true
    },
    {
      key = "Terraform"
      value = "true"
      propagate_at_launch = true
    },
    {
      key = "Description"
      value = "Hotel accomodations ECS Instance"
      propagate_at_launch = true
    }
  ]
}
