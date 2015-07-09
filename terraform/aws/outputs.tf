output "server_address" {
    value = "${aws_instance.server.0.public_ip}"
}

# FIXME: This always returns the first ip address
output "servers_private_ip" {
    value = [
    	"${aws_instance.server.0.private_ip}",
    	"${aws_instance.server.1.private_ip}",
    	"${aws_instance.server.2.private_ip}",
    ]
}

output "server_0_private_ip" {
    value = "${aws_instance.server.0.private_ip}"
}

output "server_1_private_ip" {
    value = "${aws_instance.server.1.private_ip}"
}

output "server_2_private_ip" {
    value = "${aws_instance.server.2.private_ip}"
}

output "server_0_id" {
    value = "${aws_instance.server.0.id}"
}

output "server_1_id" {
    value = "${aws_instance.server.1.id}"
}

output "server_2_id" {
    value = "${aws_instance.server.2.id}"
}