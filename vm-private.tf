# Create EC2 Instance for private 

# Define the security group for the Windows server (private)
resource "aws_security_group" "arcg-pcps-private-sg" {
  name        = "${var.environment}-${var.project}-windows-private-sg"
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
    Name = "ArcGIS PCPS Security Group (private)"
  }
}

# 共有されたAMIをコピー
resource "aws_ami_copy" "copied_ami" {
  name              = "copied-ami-arcg-pcps"
  source_ami_id     = "ami-047059d6626079d84"  # 共有されたAMIのIDを指定
  source_ami_region = "ap-northeast-1"      # AMIが存在するリージョン
}


# Create EC2 Instance for private
resource "aws_instance" "private-windows-server" {
  ami = aws_ami_copy.copied_ami.id
  instance_type = var.windows_instance_type_private
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.arcg-pcps-private-sg.id]
  source_dest_check = false
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = var.windows_associate_public_ip_address
  
  tags = {
    Name        = "ArcGIS PCPS Private Windows Server VM"
    Environment = var.environment
  }
}