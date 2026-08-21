resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    name = "${var.name}-private-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    name = "${var.name}-public-subnet-${count.index + 1}"
  }
}
