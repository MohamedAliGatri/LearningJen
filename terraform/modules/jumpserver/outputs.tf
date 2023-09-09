
output "bastion_sc" {
    value = aws_security_group.jumpserver_sc
}
output "server_pi" {
    value = aws_instance.bastion.public_ip
}