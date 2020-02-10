
output "ecs-role-arn" {
  value = "${aws_iam_role.ecs_role.arn}"
}

output "ecs-role-id" {
  value = "${aws_iam_role.ecs_role.id}"
}