output "region1_ec2_ssm" {
  description = "Client Instance SSM command"
  value       = var.create.region1.aws_spoke1 && var.create.region1.aws_spoke1_instance ? "aws ssm start-session --region ${var.region1_aws} --target ${module.region1_ec2[0].aws_instance.id} --profile ${var.region1_aws_profile}" : null
}

output "region1_ec2_private_ip" {
  description = "Client Private IP"
  value       = var.create.region1.aws_spoke1 && var.create.region1.aws_spoke1_instance ? module.region1_ec2[0].aws_instance.private_ip : null
}

output "region2_ec2_ssm" {
  description = "Client Instance SSM command"
  value       = var.create.region2.aws_spoke1 && var.create.region2.aws_spoke1_instance ? "aws ssm start-session --region ${var.region2_aws} --target ${module.region2_ec2[0].aws_instance.id} --profile ${var.region2_aws_profile}" : null
}

output "region2_ec2_private_ip" {
  description = "Client Private IP"
  value       = var.create.region2.aws_spoke1 && var.create.region2.aws_spoke1_instance ? module.region2_ec2[0].aws_instance.private_ip : null
}