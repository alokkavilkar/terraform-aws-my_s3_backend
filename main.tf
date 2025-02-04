provider "aws" {
  region = var.region
}

resource "random_string" "rand" {
	length 		= 24
	special		= false
	upper		= false
}

locals {
	namespace = "alok"
}

resource "aws_resourcegroups_group" "my-project-resource" {
	name = "${local.namespace}-group"

	resource_query {
		query = <<-EOF
			{	
				"ResourceTypeFilters" : ["AWS::AllSupported"],
				"TagFilters" : [{"Key" : "ResourceGroup", "Values" : ["${local.namespace}"]}]
			}
		EOF	
	}
}

resource "aws_kms_key" "kms_key" {
	tags = {
		ResourceGroup = local.namespace
	}
}

resource "aws_s3_bucket" "s3_bucket" {
	bucket 			= "${local.namespace}-s3-bucket"
	force_destroy		= var.force_destroy_state
	
	versioning {
		enabled = true
	}
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm		= "aws:kms"
				kms_master_key_id	= aws_kms_key.kms_key.arn
			}
		}
	}

	tags = {
		ResourceGroup = local.namespace
	}
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
	bucket 			= aws_s3_bucket.s3_bucket.id
	block_public_acls	= true
	block_public_policy	= true
	ignore_public_acls	= true
	restrict_public_buckets	= true
}

resource "aws_dynamodb_table" "dynamo_db_table" {
	name 		 	= "${local.namespace}-s3-dynamo"
	hash_key		= "LockID"
	billing_mode		= "PROVISIONED"
	read_capacity		= 1
	write_capacity		= 1

	attribute {
		name = "LockID"
		type = "S"
	}

	tags = {
		ResourceGroup = local.namespace
	}
}


