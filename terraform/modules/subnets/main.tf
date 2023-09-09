
resource "aws_subnet" "pub_sub_1a" {
  vpc_id = var.vpc_id
  cidr_block = var.pub_sub_1a
  availability_zone = var.avail_zone
  tags = {
    Name: "pub_sub_1a"
  }
}

#Internet gateway
resource "aws_internet_gateway" "caustaza-igw"{
    vpc_id=var.vpc_id
    tags = {
        Name : "${var.env_prefix}-igw"
    }
}
#Route table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.caustaza-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-public-rt"
  }
}
#Public subnets associations
resource "aws_route_table_association" "pub-sub-association" {
    subnet_id = aws_subnet.pub_sub_1a.id
    route_table_id = aws_route_table.public_route_table.id
}

/*resource "aws_subnet" "pub_sub_2b" {
  vpc_id = var.vpc_id
  cidr_block = var.pub_sub_2b
  availability_zone = var.second_avail_zone
  tags = {
    Name: "pub_sub_2b"
  }
}

resource "aws_subnet" "priv_sub_3a" {
  vpc_id = var.vpc_id
  cidr_block = var.priv_sub_3a
  availability_zone = var.avail_zone
  tags = {
    Name: "priv_sub_3a"
  }
}

resource "aws_subnet" "priv_sub_4b" {
  vpc_id = var.vpc_id
  cidr_block = var.priv_sub_4b
  availability_zone = var.second_avail_zone
  tags = {
    Name: "priv_sub_4b"
  }
}

resource "aws_subnet" "priv_sub_5a" {
  vpc_id = var.vpc_id
  cidr_block = var.priv_sub_5a
  availability_zone = var.avail_zone
  tags = {
    Name: "priv_sub_5a"
  }
}

resource "aws_subnet" "priv_sub_6b" {
  vpc_id = var.vpc_id
  cidr_block = var.priv_sub_6b
  availability_zone = var.second_avail_zone
  tags = {
    Name: "priv_sub_6b"
  }
}*/
/*
resource "aws_route_table_association" "pub-sub-association-2" {
    subnet_id = aws_subnet.pub_sub_2b.id
    route_table_id = aws_route_table.public_route_table.id
}
#Elastic IP
resource "aws_eip" "nat_eip_1"{
    domain = "vpc"
}
#Nat gateway creation
resource "aws_nat_gateway" "nat_gateway_1" {
    allocation_id = aws_eip.nat_eip_1.id
    subnet_id = aws_subnet.pub_sub_1a.id
}
#Route table
resource "aws_route_table" "private_route_table" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
    }
}
#Private subnets associations
resource "aws_route_table_association" "priv_sub_association_1" {
    subnet_id = aws_subnet.priv_sub_3a.id
    route_table_id = aws_route_table.private_route_table.id
} 
resource "aws_route_table_association" "priv_sub_association_2" {
    subnet_id = aws_subnet.priv_sub_4b.id
    route_table_id = aws_route_table.private_route_table.id
} 
resource "aws_route_table_association" "priv_sub_association_3" {
    subnet_id = aws_subnet.priv_sub_5a.id
    route_table_id = aws_route_table.private_route_table.id
} 
resource "aws_route_table_association" "priv_sub_association_4" {
    subnet_id = aws_subnet.priv_sub_6b.id
    route_table_id = aws_route_table.private_route_table.id
} */