output "region" {
  value       = var.region
  description = "aws region"
}

output "instance_arn" {
  value       = "${aws_instance.mc_auto_instance.arn}"
  description = "arn of the mc server instance"
}

output "instance_id" {
  value       = "${aws_instance.mc_auto_instance.id}"
  description = "id of the mc server instance"
}

output "lambda_password" {
  value       = var.lambda_password
  description = "The password used to log into the lambda function and control the server."
}
