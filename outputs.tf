output "back_end_config" {
	value = {
		bucket      	= aws_s3_bucket.s3_bucket.bucket
		region    	= var.region
		role_arn	= aws_iam_role.iam_role.arn
		dynamodb_table	= aws_dynamodb_table.dynamo_db_table.name
	}
}
