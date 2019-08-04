# Start here
my_vpc_name = "sdn-lab"

# Region - Singapore
region = "ap-southeast-1"
availability_zone = "ap-southeast-1b"

my_key_name = "lab" #VM's Key pair, upload this before starting

# VPC Network configuration
my_cidr_block = "172.18.0.0/16"

# Public and Private Subnets
pub_sub = "172.18.254.0/24"
pri_sub = "172.18.0.0/20"

# Instance size configs
my_bastion_instance_type = "t2.small"
my_ubuntu_instance_type = "t2.small"

# Region ap-southeast-1 AMIs
my_ubuntu_ami = "ami-010162ac5374d76d3" # Ubuntu 14.04 LTS
my_bastion_ami = "ami-76aafe0a" # Bastion
my_csr_ami = "ami-0556b08f9ffb83c56" # Cisco CSR