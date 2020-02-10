To be able to create the stated infrastructure we are using Terraform.
This Terraform module creates ECS resources on AWS.

This module focuses purely on AWS ECS and its dependant services. Therefore only these resources can be created with this module:

- ECS
- IAM
- ALB
- Auto-scaling groups
- Security groups
- Route 53 record
