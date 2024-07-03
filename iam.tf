
data "aws_caller_identity" "myrole" {}
locals {
	principal_arns = data.aws_caller_identity.myrole.arn
}

resource "aws_iam_role" "iam_role" {
	name = "${local.namespace}-iam-role"
	
	assume_role_policy = <<-EOF
	{
		"Version": "2012-10-17",
		"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
			"AWS": ${jsonencode(local.principal_arns)}
			},
			"Action": "sts:AssumeRole"
		}
		]
	}
  EOF


	
	tags = {
		ResourceGroup = local.namespace
	}
}


data "aws_iam_policy_document" "policy_doc" {
	statement {
		actions = ["s3: ListBucket"]
		resources = [aws_s3_bucket.s3_bucket.arn]
	}
	
	statement {
		actions = ["s3:GetObject", "s3:PutObject" , "s3:DeleteObject"]
	resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
	}

	statement {
		actions = [
			"dynamodb:GetItem",
			"dynamodb:DeleteItem",
			"dynamodb:PutItem"	
		]
		resources = [aws_dynamodb_table.dynamo_db_table.arn]
	}
}

resource "aws_iam_policy" "my_policy" {
	name 			= "${local.namespace}-backend-policy"
	path			= "/"
	policy			= data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
	role 			= aws_iam_role.iam_role.name
	policy_arn		= aws_iam_policy.my_policy.arn
}

