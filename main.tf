data "aws_vpc" "pluto_terraform_vpc"{
    filter{
        name="tag:Name"
        values=["PLUTO-TERRAFORM-VPC"]
    }
}
data "aws_route_table" "route_table"{
    filter{
        name="tag:Name"
        values=["PLUTO-TERRAFORM-VPC-public"]
    }
}
resource "aws_route_table_association" "route_table_association"{
    subnet_id=aws_subnet.pluto_terraform_subnet.id
    route_table_id=data.aws_route_table.route_table.id
}

resource "aws_subnet" "pluto_terraform_subnet"{
    vpc_id=data.aws_vpc.pluto_terraform_vpc.id
    cidr_block="10.10.3.0/24"
    availability_zone="eu-central-1a"
    tags={
        Name="PLUTO-TERRAFORM-SUBNET-3"
    }
}
resource "aws_key_pair" "PC-03"{
    key_name="PC-03@indirizzo.email" //   ~/.ssh/id_rsa.pub
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNIkKiWeVqtfP4pQ1y18VdqzofDZlFKHJzuX3vE1pmkGfQWaJRFHtSH71qUK69J9nlxoV2/0dz4DUiHrT3kKIzlWZcQ438k7M72asG+pz/DVIusKQowkTIugIdAjzb/BkLJfGkgjr+i0rOilzbZ4/WyUOYJSByrsoW53vtDo8iVA+XiSL7V7buQjhCXQy8QfNtK4XXMmNAR3T7j0wwXIGMZSo15UGe2cQsSmRlM4E1j1XN8WmSOr+aeacMRlBt44pjIorVm7eK7miAWogWlRkp74nRSR3wC0IfUyjBsuuG0tsvO5fTQUrW3vec5AHc8Zh8v4rHZCavD0Oe5h51aPi/"
}
resource "aws_security_group" "instance_sg"{
    name="SecurityGroup-pc-03"
    description="security group for EC2-pc-03"
    vpc_id=data.aws_vpc.pluto_terraform_vpc.id
    tags={
        Name="SecurityGroup-pc-03"
    }
    ingress{
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
    }
}
resource "aws_instance" "ec2_instance"{
    ami="ami-0f568b82f7a63bf7c"
    instance_type="t2.micro"
    subnet_id = aws_subnet.pluto_terraform_subnet.id
    vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
    associate_public_ip_address = true
    tags={
        Name="EC2-03"
    }
    key_name = aws_key_pair.PC-03.key_name
}
output "EIP" {
    value = aws_instance.ec2_instance.public_ip
}
