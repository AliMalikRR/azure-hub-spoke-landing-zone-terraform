locals {
  common_tags = {
    Enviroment = "Production"
    Name       = "Hub&Spoke"
    Region     = var.region
  }
}