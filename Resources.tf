# Creating VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}



# Creating Subnets

# First subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = "public_subnet_1"
  }
}

# Second subnet
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = "public_subnet_2"
  }
}


# Creating Route table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id


  tags = {
    Name = "rt-practice"
  }
}

# Route table association (connecting route table with both subnets)
resource "aws_route_table_association" "rt-subnet1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "rt-subnet2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.my_rt.id
}

# Creating Internet gateway
resource "aws_internet_gateway" "my_IG" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IG"
  }
}

# connecting Internet gateway to route table
resource "aws_route" "Ig_RT" {
  route_table_id         = aws_route_table.my_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_IG.id
}

# Creating Security group
resource "aws_security_group" "my_sg" {
  name        = "security-group"
  description = "my-security-group"
  vpc_id      = aws_vpc.my_vpc.id

   ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "all"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "all"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}



# Creating Load Balancer

resource "aws_lb" "my_load_balancer" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets            = [aws_subnet.subnet-1.id
                        , aws_subnet.subnet-2.id]

  


  tags = {
    Environment = "production"
  }

 # cross_zone_load_balancing   = true

}


resource "aws_lb_target_group" "target_group1" {
  name        = "tf-example-lb-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.my_vpc.id
}

/*

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group1.arn
    type             = "forward"
  }

}
*/

# Creating Auto scaling policy

# creating launch temeplate
resource "aws_launch_template" "my_launch_temp" {
  image_id      = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.my_sg.id ]
  
  

  tags = {
    "Name" = "my-temp"
  }
}

# creating auto scaling group
resource "aws_autoscaling_group" "my_asg" {
  #availability_zones = ["eu-west-1a", "eu-west-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier = [ aws_subnet.subnet-1.id
                         , aws_subnet.subnet-2.id ]
 

# using above created launch template to launch instance
  launch_template {
    id      = aws_launch_template.my_launch_temp.id
    version = "$Latest"
  }
}