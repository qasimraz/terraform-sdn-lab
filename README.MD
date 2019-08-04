# Terraform SDN Lab 

This repository contains the Terraform blueprint to provision an SDN lab in AWS

### Requirements
- Terraform v0.11.14 ([TFswitch](https://warrensbox.github.io/terraform-switcher/) to downgrade)


### Terraform Setup

```
export TF_VAR_access_key=''
export TF_VAR_secret_key=''
export TF_VAR_personal_ssh_key_path='/home/.ssh/lab.pem'
```

### Provision 
```
cd sdn-lab/
terraform init
terraform plan
terraform apply
```

To destroy
```
cd sdn-lab/
terraform destroy
```

### View the setup

[Terraform inventory](https://github.com/adammck/terraform-inventory) shows the setup/IP addresses as an [Ansible inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

```
$ brew install terraform-inventory
$ terraform-inventory -inventory terraform.tfstate
```

### Interacting the setup

The lab uses a Bastion/NAT. To tunnel your traffic through that, use [sshuttle](https://github.com/sshuttle/sshuttle), another good option is [OpenVPN](https://aws.amazon.com/blogs/awsmarketplace/setting-up-openvpn-access-server-in-amazon-vpc/).

The shuttle command for this specific lab (requires superuser permission)
```
$ sshuttle -r ec2-user@<bastion_public_IP> 172.18.0.0/16
```

After which you can access the private subnet directly