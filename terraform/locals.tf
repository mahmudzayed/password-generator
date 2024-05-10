## Define local variables ##

locals {
  # Project name/alias
  project = "zhm"
  prefix  = "${local.project}-${var.environment}" # e.g. zhm-demo

  # Use Availability Zones 'a' & 'b' for selected region
  az1_name = "${var.aws_region}a"
  az2_name = "${var.aws_region}b"

  # Set EKS cluster name
  eks_cluster_name = "${local.prefix}-eks-cluster"
}
