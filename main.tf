terraform {
  backend "atlas" {
    name = "tyloo/tfeMoveState"
    address = "https://app.terraform.io"
  }
}
module "example" {
  source = "github.com/martinhristov90/tfeMoveStateModule"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${module.example.display}"
  }
}