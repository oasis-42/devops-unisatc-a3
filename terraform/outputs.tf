output "ecr_repository_url" {
  description = "ECR repo URI from the test_devops module"
  value       = module.test_devops.ecr_repository_url
}