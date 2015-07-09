resource "aws_instance" "server" {
    ami = "${lookup(var.ami, concat(var.region, "-", var.platform))}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    count = "${var.servers}"

    # Can both be declared and default to VPC? Nope.
    # security_groups = ["${aws_security_group.consul.name}"]
    vpc_security_group_ids = [
        "${aws_security_group.consul.id}",
        "sg-b998a9dd"
    ]
    subnet_id = "subnet-e487c493"

    connection {
        user = "${lookup(var.user, var.platform)}"
        key_file = "${var.key_path}"
    }

    #Instance tags
    tags {
        Name = "${var.tagName}-${count.index}"
    }

    provisioner "file" {
        source = "${path.module}/scripts/${var.platform}/upstart.conf"
        destination = "/tmp/upstart.conf"
    }

    provisioner "file" {
        source = "${path.module}/scripts/${var.platform}/upstart-join.conf"
        destination = "/tmp/upstart-join.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "echo ${var.servers} > /tmp/consul-server-count",
            "echo ${aws_instance.server.0.private_ip} > /tmp/consul-server-addr",
        ]
    }

    provisioner "remote-exec" {
        scripts = [
            "${path.module}/scripts/${var.platform}/install.sh",
            "${path.module}/scripts/${var.platform}/server.sh",
            "${path.module}/scripts/${var.platform}/service.sh",
        ]
    }
}

resource "aws_security_group" "consul" {
    name = "consul"
    description = "Consul internal traffic + maintenance."

    # Fixes Error authorizing security group egress rules:
    #   InvalidParameterValue:
    #   Only Amazon VPC security groups may be used with this operation.
    vpc_id = "${var.vpc_id}"

    # These are for internal traffic
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    # These are for maintenance
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # This is for outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
