variable "namespace" {
	type = string
	default = "s3backend"
	description = "The project namespace to use unique resources"
}

variable "principal_arn" {
	type = list(string)
	default = null
}

variable "force_destroy_state" {
	default = true
	type 	= bool
}

variable "region" {
	type = string
	default = "us-east-1"
}

