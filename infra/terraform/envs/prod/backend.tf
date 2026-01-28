terraform {
  backend "s3" {
    bucket         = "andrewlinzie-tc2-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "andrewlinzie-tc2-tflock"
    encrypt        = true
  }
}
