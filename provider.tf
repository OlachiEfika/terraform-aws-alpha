terraform {
    backend "s3" {
        bucket         = "my-terraform-tf-state-bucket"
        key            = "terraform.tfstate"
        region         = "ca-central-1"
        dynamodb_table = "my-terraform-remote-state-lock"
    }
}
