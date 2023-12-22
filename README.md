# How to use
This terraform project uses an S3 backend to keep the statefile and DynamoDB for locking mechanism. Although its simpler to run with a local state file, remote state should be used to ease colloboration on the project
- Create S3 Bucket to store remote state and update `backend.tf` file accordingly
- Create DynamoDB Table with the same name in `backend.tf` file
    - It has to have `LockID` as `partitionKey`
    - Its better to create  `on-demand`
- Set variables (mandatory)
    - vpc_id : ID of existing vpc
    - private_subnets : List of Private Subnets in the vpc
    - public_subnetes : List of Public Subnets in the vpc
- Set variables (optional)
    - aws_auth_users  : List of dictionaries to map AWS IAM Users to K8s Users & group.
    - aws_auth_roles  : List of dictionaries to map AWS IAM Roles to K8s Users & group.
    **PS**: Either one of the above variable is required if the cluster is used by a user other than the one who created the cluster. Its always better to use `Role mapping` instead of `User mapping`

Run the following commands
```
tf init
tf apply
```

# How it works
It uses [terraform-eks-module](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v19.21.0) to create EKS cluster. It has a simple way to assign role to EKS Nodes. Thanks to the following role attached to EKS Nodes, any pod can run any s3 commands to any s3 bucket in the same account
```
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
```