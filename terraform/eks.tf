## Deploy AWS EKS cluster with managed no group ##

module "eks" {
  # source  = "terraform-aws-modules/eks/aws"
  # version = "~> 20.0"
  source = "./modules/terraform-aws-eks" # used v20.9.0 for module (https://github.com/terraform-aws-modules/terraform-aws-eks/releases/tag/v20.9.0)

  cluster_name    = local.eks_cluster_name
  cluster_version = "1.28"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  control_plane_subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.large"] # Spec: 2 vCPU & 8.0 GiB Memory
    disk_size      = 10           # in GiB
  }

  eks_managed_node_groups = {
    private-ng = {
      desired_size = var.eks_nodegroup_asg_config["desired_size"]
      max_size     = var.eks_nodegroup_asg_config["max_size"]
      min_size     = var.eks_nodegroup_asg_config["min_size"]

      instance_types  = var.eks_nodegroup_instance_type
      capacity_type   = "ON_DEMAND"
      disk_size       = var.eks_nodegroup_disk_size_in_gb # Node disk size in GiB
      ami_type        = var.eks_nodegroup_ami_type        # OS & arch.
      release_version = var.eks_nodegroup_ami_id          # AMI version

      labels = {
        project = local.project
      }
    }
  }

  # Add current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  depends_on = [
    aws_vpc.main,
    aws_subnet.private_subnet_1,
    aws_subnet.private_subnet_2,
    aws_subnet.public_subnet_1,
    aws_subnet.public_subnet_2,
    aws_route_table.private,
    aws_route_table.public,
    aws_nat_gateway.natgw1,
    aws_internet_gateway.main
  ]

  tags = {
    environment       = var.environment
    project           = "${local.project}"
    terraform_managed = "true"
  }
}

## OUTPUTS ##
output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "eks_cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
}

output "eks_cloudwatch_log_group_name" {
  value       = module.eks.cloudwatch_log_group_name
  description = "Name of cloudwatch log group created"
}

output "eks_cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to communicate with the cluster"
  sensitive   = true
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for your Kubernetes API server"
}

output "eks_cluster_primary_security_group_id" {
  value       = module.eks.cluster_primary_security_group_id
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
}

output "eks_cluster_tls_certificate_sha1_fingerprint" {
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "ID of the cluster security group"
}

output "eks_node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "ID of the node shared security group"
}

output "eks_oidc_provider" {
  value       = module.eks.oidc_provider
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
}
