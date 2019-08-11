# AWS access and secret key to access AWS
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "lab" {
  source = "../modules/sdn-lab"
  # Input Parameters for Lab setup
  region = "${var.region}"
  secret_key = "${var.secret_key}"
  access_key = "${var.access_key}"
  my_key_name = "${var.my_key_name}"
  my_vpc_name = "${var.my_vpc_name}"
  pub_sub = "${var.pub_sub}"
  my_cidr_block = "${var.my_cidr_block}"
  pri_sub = "${var.pri_sub}"
  my_bastion_ami = "${var.my_bastion_ami}"
  my_bastion_instance_type = "${var.my_bastion_instance_type}"
  availability_zone = "${var.availability_zone}"
}

# Create ODL instance
resource "aws_instance" "odl" {
  ami = "${var.my_ubuntu_ami}"
  instance_type = "${var.my_ubuntu_instance_type}"
  key_name = "${var.my_key_name}"
  subnet_id = "${module.lab.aws_subnet_private}"
  security_groups = ["${module.lab.aws_security_group_private}"]
  availability_zone = "${module.lab.aws_availability_zone_private}"
  tags {
    Name = "${var.my_vpc_name}-odl"
    User = "ubuntu"
    Type = "odl"
  }
}

# Create CSR1 instance
resource "aws_instance" "csr1" {  
  ami = "${var.my_csr_ami}"
  instance_type = "m4.2xlarge"
  key_name = "${var.my_key_name}"
  subnet_id = "${module.lab.aws_subnet_private}"
  security_groups= ["${module.lab.aws_security_group_private}"]
  availability_zone = "${module.lab.aws_availability_zone_private}"
  ebs_optimized = 1
  tags {
    Name = "${var.my_vpc_name}-csr1"
    User = "ec2-user"
    Type = "csr"
  }
}

# Create CSR2 instance
resource "aws_instance" "csr2" {
  ami = "${var.my_csr_ami}"
  instance_type = "m4.2xlarge"
  key_name = "${var.my_key_name}"
  subnet_id = "${module.lab.aws_subnet_private}"
  security_groups= ["${module.lab.aws_security_group_private}"]
  availability_zone = "${module.lab.aws_availability_zone_private}"
  ebs_optimized = 1
  tags {
    Name = "${var.my_vpc_name}-csr2"
    User = "ec2-user"
    Type = "csr"
  }
}

# Create data subnet between CSR1 and CSR2
resource "aws_subnet" "LINK_01" {
  vpc_id = "${module.lab.aws_vpc}"
  cidr_block = "172.18.253.0/24" # Range: 172.18.253.0 - 172.18.253.3
  availability_zone = "${module.lab.aws_availability_zone_private}"
  tags {
    Name = "${var.my_vpc_name}-LINK_01"
  }
}

# Add LINK_01 network interface to CSR1
resource "aws_network_interface" "csr1_ge0-0-0" {
  description = "csr1_ge0-0-0"
  subnet_id       = "${aws_subnet.LINK_01.id}"
  attachment {
    instance     = "${aws_instance.csr1.id}"
    device_index = 1
  }
}

# Add LINK_01 network interface to CSR2
resource "aws_network_interface" "csr2_ge0-0-0" {
  description = "csr2_ge0-0-0"
  subnet_id       = "${aws_subnet.LINK_01.id}"
  attachment {
    instance     = "${aws_instance.csr2.id}"
    device_index = 1
  }
}