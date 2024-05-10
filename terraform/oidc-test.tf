# data "tls_certificate" "eks" {
#   # url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
#   url = modue.eks.module.eks.cluster_oidc_issuer_url
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list = ["sts.amazonaws.com"]
#   # thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   thumbprint_list = [module.eks.cluster_tls_certificate_sha1_fingerprint]
#   # url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
#   url = module.eks.cluster_oidc_issuer_url
# }

## TEST

/*
data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}

# needed for IRSA
output "test_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}
*/
