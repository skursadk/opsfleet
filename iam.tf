# module "dev_irsa" {
#   version = "4.24.1"
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

#   create_role      = true
#   role_name_prefix = "DevIRSA"

#   provider_url = module.eks.cluster_oidc_issuer_url
#   role_policy_arns = [
#     aws_iam_policy.dev_irsa_policy.arn
#   ]

#   oidc_fully_qualified_subjects  = ["system:serviceaccount:default:dev-sa"]
#   oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
# }

data "aws_iam_policy_document" "dev_policy" {
  statement {
    sid     = "S3Access"
    effect  = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}

resource "aws_iam_policy" "dev_irsa_policy" {
  name   = "dev-irsa-policy"
  policy = data.aws_iam_policy_document.dev_policy.json
}

resource "aws_iam_policy" "eks_node_additional_policy" {
  name   = "eks-node-additional-policy"
  policy = data.aws_iam_policy_document.dev_policy.json
}