module "network" {
  source = "./modules/network"

  name               = "yiro"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnets_cidr = [
    "10.0.1.0/24",
    "10.0.1.0/24"
  ]

  private_subnets_cidr = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

# module "alb" {
#   source = "./modules/alb"
#
# }
