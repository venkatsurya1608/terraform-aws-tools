module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-tf"    # give only backend or var.common_tags.Component
  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0901b3bc038adbb53"] 
  # convert StringList to list and get first element
  subnet_id = "subnet-02eef0a1b1c30ffa4"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  

  tags = merge(
    {
        Name = "jenkins-tf"    
    }
  )
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-agent"    
  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0901b3bc038adbb53"] 
  # convert StringList to list and get first element
  subnet_id = "subnet-02eef0a1b1c30ffa4"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  

  tags = merge(
    {
        Name = "jenkins-agent"    
    }
  )
}

resource "aws_key_pair" "nexus" {
  key_name   = "nexus"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGB/HuwOlK9vKk0LInlSdbvrG0HSlCjgCDJIenarzPAZ h9010@Harish"
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0901b3bc038adbb53"]
  # convert StringList to list and get first element
  subnet_id = "subnet-02eef0a1b1c30ffa4"
  ami = data.aws_ami.nexus_ami_info.id
  key_name = aws_key_pair.nexus.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      allow_overwrite = true
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    }
  ]

}