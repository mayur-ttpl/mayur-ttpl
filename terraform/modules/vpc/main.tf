# get available AZs
data "aws_availability_zones" "available_azs" {}

# define VPC
resource "aws_vpc" "main_network" {
  cidr_block = "${var.vpc_cidr_block}"
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# define ${var.az_count} private subnets (one for each AZ)
resource "aws_subnet" "private_subnet" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc.main_network.cidr_block, 8, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available_azs.names[count.index]}"
  vpc_id                  = "${aws_vpc.main_network.id}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  }
}

# define ${var.az_count} public subnets (one for each AZ)
resource "aws_subnet" "public_subnet" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc.main_network.cidr_block, 8, var.az_count + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available_azs.names[count.index]}"
  vpc_id                  = "${aws_vpc.main_network.id}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
  }
}

# define IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main_network.id}"
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main_network.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

# define NAT gateway for each private subnet
resource "aws_eip" "nat_gateway_eip" {
  count      = "${var.nat_count}"
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.name_prefix}-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = "${var.nat_count}"
  #subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.nat_gateway_eip[count.index].id
  #allocation_id = "${element(aws_eip.nat_gateway_eip.*.id, count.index)}"
  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

# define route table for each private subnet
resource "aws_route_table" "private_route_table" {
  count  = "${var.nat_count}"
  vpc_id = "${aws_vpc.main_network.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }

  tags = {
    Name = "${var.name_prefix}-nat-gateway-route-table"
  }
}

# associate route tables with private subnets
resource "aws_route_table_association" "private_route_table_association" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.private_route_table[0].id
}