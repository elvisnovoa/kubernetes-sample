output "subnets" {
  value = "${aws_subnet.public.*.id}"
}

output "control_plane_security_group" {
  value = "${aws_security_group.control_plane.id}"
}

output "vpc" {
  value = "${aws_vpc.eks_vpc.id}"
}