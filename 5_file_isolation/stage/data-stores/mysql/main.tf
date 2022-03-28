terraform {
    backend "s3" {
        bucket = "example-terraform-state-zerolens"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "eu-west-1"

        dynamodb_table = "terraform-locks-zerolens"
        encrypt = true
    }
}

provider "aws" {
    region = "eu-west-1"
}

resource "aws_db_instance" "example-db" {
    identifier_prefix = "terraform-up-and-running"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    db_name = "example"
    username = "admin"
    
    # Set a password?
    password = var.db_password
}