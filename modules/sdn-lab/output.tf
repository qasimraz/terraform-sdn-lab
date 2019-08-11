output "aws_subnet_private" {
  value = "${aws_subnet.private.id}"
}
output "aws_security_group_private" {
  value = "${aws_security_group.lab-private.id}"
}
output "aws_availability_zone_private" {
  value = "${aws_subnet.private.availability_zone}"
}
output "aws_vpc" {
  value = "${aws_vpc.vpc.id}"
}
output "bastion_address" {
  value = "${aws_eip.public.public_ip}"
}