output "openvpn_public_ip" {
  value = aws_eip.openvpn.public_ip
}

output "openvpn_eni_id" {
  description = "ID of the OpenVPN instance's primary network interface"
  value       = aws_instance.openvpn.primary_network_interface_id
}
