# AWS access and secret key
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.my_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "${var.my_vpc_name}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.my_vpc_name}-igw"
  }
}

# Create a Route in the Main Route Table
resource "aws_route" "lab-public" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id  = "${aws_network_interface.bastion.id}" # Forward our private subnet traffic to this interface
  }
  tags = {
    Name = "lab-private"
  }
}

# Create Public Security Groups
resource "aws_security_group" "lab-public" {
  name = "lab-public"
  description = "Allow lab testing traffic"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8181
    to_port         = 8181
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 9001
    to_port         = 9001
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["172.18.0.0/16"]
  }
  tags {
    Name = "lab-public"
    }
}

# Create Private Security Groups - This can be enhanced for further security 
resource "aws_security_group" "lab-private" {
  name = "lab-private"
  description = "Allow all traffic"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "lab-private"
    }
}

# Create a Private Subnet
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.pri_sub}"
  availability_zone = "${aws_subnet.public.availability_zone}"
  tags {
    Name = "${var.my_vpc_name}-private"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.pub_sub}"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "${var.my_vpc_name}-public"
  }
}

# Associate Public Subnet to Main routing table
resource "aws_route_table_association" "assoc-public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}

# Associate Private Subnet to Private routing table
resource "aws_route_table_association" "assoc-private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Create the bastion instance
resource "aws_instance" "bastion" {
  ami = "${var.my_bastion_ami}"
  instance_type = "${var.my_bastion_instance_type}"
  key_name = "${var.my_key_name}"
  availability_zone = "${aws_subnet.public.availability_zone }"
  tags {
    Name = "${var.my_vpc_name}-bastion"
    User = "ec2-user"
  }
  network_interface{
    device_index            = 0
    network_interface_id    = "${aws_network_interface.bastion.id}"
  }
}

# Create the NAT interface
resource "aws_network_interface" "bastion" {
  subnet_id       = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.lab-public.id}"]
  source_dest_check = 0
}

resource "aws_eip_association" "public_eip_assoc" {
  allocation_id = "${aws_eip.public.id}"
  network_interface_id = "${aws_network_interface.bastion.id}"
}

resource "aws_eip" "public" {
  vpc = true
}