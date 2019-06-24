terraform {
  backend "atlas" {
    name = "tyloo/tfeMoveState"
    address = "https://app.terraform.io"
  }
}
module "example" {
  source = "github.com/martinhristov90/tfeMoveStateModule?ref=v0.0.1"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${module.example.display}"
  }
}