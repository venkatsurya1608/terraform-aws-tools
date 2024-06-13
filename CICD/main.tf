module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-tf"    # give only backend or var.common_tags.Component
  instance_type          = "t3.micro"
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

module "jenkins-agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-agent"    
  instance_type          = "t3.micro"
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
    # {
    #   name    = "nexus"
    #   type    = "A"
    #   ttl     = 1
    #   allow_overwrite = true
    #   records = [
    #     module.nexus.private_ip
    #   ]
    #   allow_overwrite = true
    # }
  ]

}
