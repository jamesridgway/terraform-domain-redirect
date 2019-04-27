provider "aws" {
  alias =  "use1"
}

data "aws_region" "current" {
}
data "aws_caller_identity" "current" {
}