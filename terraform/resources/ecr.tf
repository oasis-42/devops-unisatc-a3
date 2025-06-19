resource "aws_ecr_repository" "ecr_strapi" {
  name                 = "strapi"
  image_tag_mutability = "MUTABLE"
  encryption_configuration { encryption_type = "AES256" }
}