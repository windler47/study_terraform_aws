provider "aws" {
  region = "eu-central-1" 
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}
