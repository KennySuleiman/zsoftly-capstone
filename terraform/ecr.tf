resource "aws_ecr_repository" "app" {
  name                 = "zsoftly-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}
