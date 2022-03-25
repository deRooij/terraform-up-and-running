terraform {
    backend "s3" {
        bucket = "example-terraform-state-zerolens"
        key = "global/s3/terraform.tfstate"
        region = "eu-west-1"

        dynamodb_table = "terraform-locks-zerolens"
        encrypt = true
    }
}

provider "aws" {
    region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "example-terraform-state-zerolens"

    tags = {
        Name = "Zerolens state"
        Environment = "testing"
    }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state.bucket
    versioning_configuration {
        status = "Enabled"
    }
}

# resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle_configuration" {
#     bucket = aws_s3_bucket.terraform_state.bucket.id

#     rule {
      
#     }

# }

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.bucket

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-locks-zerolens"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The arn of our s3 state bucket"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "The name of our dynoamodb table"
}