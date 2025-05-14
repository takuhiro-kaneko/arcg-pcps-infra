# Create EC2 Instance (public) 

# Define the security group for the Windows server
resource "aws_security_group" "arcg-pcps-sg" {
  name        = "${var.environment}-${var.project}-windows-sg"
  description = "Allow incoming connections"
  vpc_id      = aws_vpc.arcg-pcps-vpc.id
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ArcGIS PCPS Security Group"
  }
}

# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami = data.aws_ami.windows-2022.id
  instance_type = var.windows_instance_type
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.arcg-pcps-sg.id]
  source_dest_check = false
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = var.windows_associate_public_ip_address
  
  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.windows_data_volume_size
    volume_type           = var.windows_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name        = "ArcGIS PCPS Windows Server VM"
    Environment = var.environment
  }
}