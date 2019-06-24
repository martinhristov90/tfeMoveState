
resource "random_pet" "name" {
 length    = "4"
 separator = "-"
 }



output "display" {
value = "${random_pet.name.id}"
}
