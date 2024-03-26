output "module_ecr_repo_name" {
  value       = aws_ecr_repository.app_ecr_repo.name
  description = "The name of the ECR repository"
}

output "alb_dns_name" {
  value = var.domain
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "alb_listener_arn" {
  value = aws_lb_listener.web_https.arn
}
