resource "aws_vpc" "integration" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "integration"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_internet_gateway" "integration-gw" {
    vpc_id = "${aws_vpc.integration.id}"
    tags {
        Name = "integration"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

/*
  NAT Instance
*/
resource "aws_security_group" "integration-nat-sg" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.integration.id}"

    tags {
        Name = "INT-NAT-SG"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_instance" "integration-nat-a-ec2" {
    ami = "ami-e3217a80" # this is a special ami preconfigured to do NAT
    availability_zone = "ap-southeast-2a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    security_groups = ["${aws_security_group.integration-nat-sg.id}"]
    subnet_id = "${aws_subnet.integration-a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VPC NAT",
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_eip" "integration-nat-eip" {
    instance = "${aws_instance.integration-nat-a-ec2.id}"
    vpc = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "integration-a-public" {
    vpc_id = "${aws_vpc.integration.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "ap-southeast-2a"

    tags {
        Name = "IntegrationPublicA"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "integration-a-public" {
    vpc_id = "${aws_vpc.integration.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.integration-gw.id}"
    }

    tags {
        Name = "Public A Subnet"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "integration-a-public" {
    subnet_id = "${aws_subnet.integration-a-public.id}"
    route_table_id = "${aws_route_table.integration-a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "integration-a-private" {
    vpc_id = "${aws_vpc.integration.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "ap-southeast-2a"

    tags {
        Name = "IntegrationPrivateA"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "integration-a-private" {
    vpc_id = "${aws_vpc.integration.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.integration-nat-a-ec2.id}"
    }

    tags {
        Name = "Private Subnet"
        Stream = "${var.stream_tag}"
        CostCenter = "${var.costcenter_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "integration-a-private" {
    subnet_id = "${aws_subnet.integration-a-private.id}"
    route_table_id = "${aws_route_table.integration-a-private.id}"
}
