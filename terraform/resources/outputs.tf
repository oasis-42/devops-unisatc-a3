output "ecr_repository_url" {
  description = "ECR repository URI (to use as IMAGE repo)"
  value       = aws_ecr_repository.ecr_strapi.repository_url
}
