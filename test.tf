resource "random_string" "random" {
  length  = 16
  special = true
}

output "random_string" {
  value = random_string.random.result
}
