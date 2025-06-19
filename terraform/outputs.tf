output "ecr_repository_url" {
  description = "ECR repository URI (to use as IMAGE repo)"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "The public DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}
