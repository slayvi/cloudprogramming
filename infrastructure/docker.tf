# Create Docker Image:
resource "docker_image" "mlapp" {
  name = "mlapplication"
  build {
    path = "../application"
  }
}
 
# Build and push Docker Image to AWS with Shellscript
resource "null_resource" "build_and_push" {

  provisioner "local-exec" {
    command = "./build.sh ${var.dockerfile_folder} ${aws_ecr_repository.main.repository_url}:${var.docker_image_tag} ${var.region}"
  }
}
