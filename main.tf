provider "aws" {
  region = "us-east-1" # Your desired region
}

resource "aws_instance" "stanford-vm-new-demo" {
  ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 image
  instance_type = "t2.micro"  # Instance type
  key_name      = "stanford-vm-1-key" # Pem key
  subnet_id     = "subnet-0314673b920b42c9d" # Subnet that is currently available in default VPC.

  tags = {
    Name = "stanford-vm-new-demo"
  }

# Define block device mappings for the instance
  root_block_device {
    volume_size = 10 # Size of the root volume in GB
    volume_type = "gp2" # EBS volume type (e.g., gp2, io1)
    delete_on_termination = false  # Delete root volume on termination

    # Add tags to root block device
    tags= {
      Name = "Stanford Root Volume"
    }
  }
}

# Define your Elastic IP
resource "aws_eip" "stanford-eip" {
  instance = aws_instance.stanford-vm-new-demo.id # Attaching this elastic IP to EC2 instance 'stanford-vm-1'

  tags = {
    Name = "stanford-eip"
  }
}
######################### Amazon Eventbridge and Lambda ####################

# Create IAM role for Lambda 

resource "aws_iam_role" "StanfordLambdaRole" {
  name = "StanfordLambdaRole"

  assume_role_policy = <<LAMBDAPOLICY
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }
  ]
}
LAMBDAPOLICY
}

# Lambda permissions

resource "aws_iam_policy" "LambdaPermissionsPolicy" {
  name        = "LambdaPermissionsPolicy"
  description = "Permissions for Lambda function to start EC2 instances"
  
  policy = <<LAMBDA_PERMISSIONS_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:StartInstances",
      "Resource": "*"
    }
    
  ]
}
LAMBDA_PERMISSIONS_POLICY
}
resource "aws_iam_role_policy_attachment" "lambda_permissions_attachment" {
   role = aws_iam_role.StanfordLambdaRole.name
  policy_arn = aws_iam_policy.LambdaPermissionsPolicy.arn
  
}


# Amazon EventBridge

resource "aws_cloudwatch_event_rule" "StanfordEventrule" {
event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["stopped"]
  }
}
PATTERN
}



# EventBridge Target
resource "aws_cloudwatch_event_target" "StanfordEventRuleTarget" {
  arn = aws_lambda_function.StanfordLambdaFunction.arn
  rule = aws_cloudwatch_event_rule.StanfordEventrule.id
}

# Create ZIP file of our lambda function

data "archive_file" "LambdaZip" {
  type = "zip"
  source_file = "${path.module}/src/LambdaFunction.py"
  output_path = "${path.module}/LambdaFunction.zip" 
}

# Creating our Lambda function and passing python code as a zip file

resource "aws_lambda_function" "StanfordLambdaFunction" {
  function_name = "StanfordLambdaFunction"
  filename = data.archive_file.LambdaZip.output_path
  source_code_hash = filebase64sha256(data.archive_file.LambdaZip.output_path)
  role = aws_iam_role.StanfordLambdaRole.arn
  handler = "LambdaFunction.lambda_handler"
  runtime = "python3.9"

}

# Allow Eventbridge to invoke Lambda

resource "aws_lambda_permission" "StanfordEventBridgeLambdaPermission" {
statement_id = "AllowExecutionFromCloudwatch"
action = "lambda:InvokeFunction"
function_name = aws_lambda_function.StanfordLambdaFunction.function_name
principal = "events.amazonaws.com"
source_arn = aws_cloudwatch_event_rule.StanfordEventrule.arn
}

# IAM for Lambda to send CloudWatch Logs

resource "aws_iam_policy" "CloudwatchLogPolicy" {
  policy = <<CLOUDWATCHLOGPOLICY
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : "*"
    }
  ]
}
CLOUDWATCHLOGPOLICY
}


# Attach IAM policy to role

resource "aws_iam_role_policy_attachment" "LambdaPolicyAttachment" {
  role = aws_iam_role.StanfordLambdaRole.name
  policy_arn = aws_iam_policy.CloudwatchLogPolicy.arn
}

# Create log group
resource "aws_cloudwatch_log_group" "StanfordLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.StanfordLambdaFunction.function_name}"
}

