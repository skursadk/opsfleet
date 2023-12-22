terraform {
  backend "s3" {
    profile        = "personal-profile"
    bucket         = "sk-tf-states"
    key            = "opsfleet/eks"
    region         = "us-east-1"
    dynamodb_table = "terraform-state"
  }
}