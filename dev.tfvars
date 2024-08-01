deploy_role_arn                 = "arn:aws:iam::058250566372:role/imtabut-dev-deployment-role"
deployment_role                 = "arn:aws:iam::058250566372:role/imtabut-dev-deployment-role"
assume_provider_deployment_role = "arn:aws:iam::058250566372:role/immutab_dev_api_role"

region = "us-east-1"
# region2            = "us-east-2"
environment        = "dev"
kms_key_id         = ""
aws_account_number = "058250566372"
appname            = "imtabut"
s3_bucket_name     = "imtabut-us-east-1-dev-bucket"
stage_name         = "dev"
# tags_imtabut = {
#   Application        = "imtabut"
#   Project            = "Immutable_Table_Utility"
#   Environment        = "Development"
#   DataClassification = "Sensitive"
#   Costcenter         = ""
#   Division           = "MRL"
#   Contact            = "jagdeep.singh1@mergit addck.com"
#   Consumer           = "immutab_dev@msd.com"
#   Service            = "imtabut"
#   Comment            = "Managed by Terraform"
# }


tags = {
  Application        = "imtabut"
  Project            = "Immutable_Table_Utility"
  Environment        = "Development"
  DataClassification = "Sensitive"
  Division           = "MRL"
  Consumer           = "immutab_dev@msd.com"
  Contact            = "jagdeep.singh1@merck.com"
  Service            = "Imabut"
}

default_tags = {
  Application        = "imtabut",
  Consumer           = "immutab_dev@msd.com",
  Costcenter         = "000",
  Contact            = "jagdeep.singh1@merck.com",
  Division           = "MRL",
  Environment        = "Development",
  DataClassification = "Sensitive"
  Service            = "imtabut"
}


######################################################################################
# Labels - This will create consistent naming and tagging across all resources
# All labels become part of the AWS resource name and also become tags
# Merck standard tagging is addressed
######################################################################################

resource_vars = {
  appname     = "imtabut"
  region      = "us-east-1"
  attributes  = ["dev"]
  label_order = ["appname", "region"]
}
nfs_secrets_arn                     = "arn:aws:secretsmanager:us-east-1:058250566372:secret:NFS_creds-wHP5VQ"
files_table                         = "immutable_filemaster"
jobs_table                          = "immutable_jobs"
database_name                       = "database_1"
iam_database_authentication_enabled = true
cluster_arn                         = "arn:aws:rds:us-east-1:058250566372:cluster:imtabut-us-east-1-dev-serverless-db"
###################################fv###########
#             Common                         #
##############################################      
account_no             = "058250566372"
admin_role             = "arn:aws:iam::058250566372:role/imtabut-dev-deployment-role"
vpc_id                 = "vpc-0a69daabf2d7bb906"
subnet_ids             = ["subnet-04e36b26e9944ecde", "subnet-0f88659be6c005d4a"]
vpc_security_group_ids = ["sg-0bb6e3fbe850cb86c"]
vpc_endpoints          = ["vpce-0d9dcee954c3cbfeb"]
prefix_list_ids        = ["pl-0db70414a8c30e5e9"]


#################
# Lambda module
#################
# cloudwatch_logs_retention_in_days                = 7
lambda_description = "Immutable Lambda Function"
handler            = "lambda_function.lambda_handler"
runtime            = "python3.10"
timeout            = 900
publish            = true
create_package     = false
lambda_policy      = "arn:aws:iam::058250566372:role/imtabut-us-east-1-dev-nfs-to-s3-lambda-function"
attach_policy_json = true
memory_size        = 512
######################################################################################
# Optional "User Provided" Variables
# you can modify the values below to suit your application as needed
######################################################################################

########## SNS Subscription ###########
subscriptions = {
  key_name = {
    endpoint  = "jagdeep.singh1@merck.com", #Required. Endpoint to send data to. Contents vary with the protocol.
    protocol  = "email",                    #Required. Valid values are: sqs, sms, lambda, firehose, application, email, email-json, http, https
    topic_arn = "",                         #Provide name of topic to which subscription needs to be associated with.
  }
} #Configuration block for SNS Topic Subcription. Keep empty if not required {}

other_subscriptions = {
  key_name = {
    endpoint  = "jagdeep.singh1@merck.com", #Required. Endpoint to send data to. Contents vary with the protocol.
    protocol  = "email",                    #Required. Valid values are: sqs, sms, lambda, firehose, application, email, email-json, http, https
    topic_arn = "",                         #Provide name of topic to which subscription needs to be associated with.
  }
}



########################################postgresql##############################################
# Optional "User Provided" Variables
# you can modify the values below to suit your application as needed
######################################################################################
# engine_mode = "serverless"
manage_master_user_password_rotation = true

db_subnet_group_name = "test-postgresql-group"
availability_zones   = ["us-east-1a", "us-east-1b"]
deletion_protection  = false
min_capacity         = 1
max_capacity         = 2

# rds_secondary = {
#   vpc_id     = "vpc-04d127d1a671bb2db"
#   subnet_ids = ["subnet-08de0f4260409bdeb", "subnet-004dbd28d1c59a3e6"]
# }


######################################################################################
# Optional "User Provided" Variables
# you can modify the values below to suit your application as needed
######################################################################################

########## Auto Scaling Group ###########
cooldown_timer_for_scale_up   = 300
cooldown_timer_for_scale_down = 3600
min_size                      = 1
max_size                      = 10
desired_capacity              = 1
wait_for_capacity_timeout     = 0
health_check_type             = "EC2"

image_id               = "ami-052f3cba34dfba11a"
instance_type          = "m5.xlarge"
egress_cidr_blocks     = "0.0.0.0/0"
vpc_zone_identifier    = ["subnet-04e36b26e9944ecde"]
update_default_version = true

capacity_reservation_specification = {
  capacity_reservation_preference = "open"
}
cpu_options = {
  core_count       = 2
  threads_per_core = 2
}
credit_specification = {
  cpu_credits = "standard"
}
placement = {
  availability_zone = "us-east-1a"
}

http_endpoint = "enabled"



# ####### secret manager creation#############

secret_name1 = "nfs_cred"
details = {
  test_prem_username = "value1"
  test_prem_password = "value2"
}

secret_name2 = "rds-cred"
details2 = {
  username = "postgres"
  password = "value2"
}












# #####################################################################################
# # Optional "User Provided" Variables
# # you can modify the values below to suit your application as needed
# ######################################################################################

# Queue

fifo_queue                 = false
use_name_prefix            = false
receive_wait_time_seconds  = null
visibility_timeout_seconds = 3600
create_dlq                 = true
queue_policy_statements = {
  account = {
    sid = "AccountReadWrite"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
    ]
    principals = [
      {
        type        = "AWS"
        identifiers = ["arn:aws:iam::058250566372:root"]
      }
    ]
  }
}
create_dlq_queue_policy = true
dlq_queue_policy_statements = {
  account = {
    sid = "AccountReadWrite"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
    ]
    principals = [
      {
        type        = "AWS"
        identifiers = ["arn:aws:iam::058250566372:root"]
      }
    ]
  }
}
