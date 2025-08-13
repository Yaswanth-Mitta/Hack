resource "aws_instance" "web" {
  ami           = "ami-04f59c565deeb2199"
  instance_type = "t2.medium"
  key_name      = "mittanv"

  # The instance will be launched into the default VPC and its default security group
  # as no VPC or security group is explicitly specified.

  user_data = file("${path.module}/setup_k8s.sh")

  tags = {
    Name = "Mitta-Kubeadm"
  }
}
