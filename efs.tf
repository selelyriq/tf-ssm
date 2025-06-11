# EFS File System
resource "aws_efs_file_system" "informatica_cluster" {
  creation_token = "informatica-cluster-efs"
  encrypted      = true

  performance_mode                = "generalPurpose"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 100

  tags = {
    Name = "informatica-cluster-efs"
  }
}

# EFS Mount Target for the public subnet
resource "aws_efs_mount_target" "informatica_cluster" {
  file_system_id  = aws_efs_file_system.informatica_cluster.id
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.efs.id]
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name_prefix = "informatica-cluster-efs-"
  vpc_id      = aws_vpc.main.id

  # NFS access from EC2 instances
  ingress {
    description     = "NFS from EC2"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.informatica_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "informatica-cluster-efs-sg"
  }
}

# EFS Access Point (optional, for better access control)
resource "aws_efs_access_point" "informatica_cluster" {
  file_system_id = aws_efs_file_system.informatica_cluster.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/opt/informatica_cluster"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "informatica-cluster-efs-access-point"
  }
}