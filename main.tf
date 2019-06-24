resource "random_pet" "name" {
  length    = "4"
  separator = "-"
}
output "display" {
  value = "${random_pet.name.id}"
}
resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${random_pet.name.id}"
  }
}