
variable "aws_region" {
  type        = string
  description = "AWS Region in which to create resources"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Project environment"
  default     = "demo"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for main VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_1_cidr" {
  type        = string
  description = "CIDR for private subnet 1"
  default     = "10.0.0.0/24"
}

variable "private_subnet_2_cidr" {
  type        = string
  description = "CIDR for private subnet 2"
  default     = "10.0.1.0/24"
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR for public subnet 1"
  default     = "10.0.100.0/24"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR for public subnet 2"
  default     = "10.0.101.0/24"
}

variable "eks_version" {
  # Ref.: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#available-versions
  type        = string
  description = "Target Kubernetes version"
  default     = "1.28"
}

variable "eks_nodegroup_ami_type" {
  # Ref.: see 'amiType' at https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html
  type        = string
  description = "AMI type for node group"
  default     = "AL2_x86_64"
}

variable "eks_nodegroup_ami_id" {
  # Ref.: https://github.com/awslabs/amazon-eks-ami/blob/main/CHANGELOG.md
  type        = string
  description = "AMI release version for node group"
  default     = "1.28.8-20240506"
}

variable "eks_nodegroup_disk_size_in_gb" {
  type        = string
  description = "EC2 disk size in GB for node group"
  default     = "10"
}

variable "eks_nodegroup_instance_type" {
  type        = list(string)
  description = "EC2 instance type for node group"
  default     = ["t3.large"]
}

variable "eks_nodegroup_asg_config" {
  type        = map(any)
  description = "Auto scaling group instance counts for node group"
  default = {
    desired_size = 1,
    max_size     = 5,
    min_size     = 1
  }
}
