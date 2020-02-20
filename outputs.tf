output "Dev_Public_IP"{
  value = "${aws_instance.dev.public_ip}"
}
output "Dev_Private_IP" {
  value = "${aws_instance.dev.private_ip}"
}

output "Prod_Public_IP" {
  value = "${aws_instance.prod.public_ip}"
}

output "Prod_Private_IP" {
  value = "${aws_instance.prod.private_ip}"
}

output "Jenkins_Public_IP" {
  value = "${aws_instance.jenkins.public_ip}"
}

output "Jenkins_Private_IP" {
  value = "${aws_instance.jenkins.private_ip}"
}

output "Jump_Public_IP" {
  value = "${aws_instance.jump.public_ip}"
}

output "Jump_Private_IP" {
  value = "${aws_instance.jump.private_ip}"
}
