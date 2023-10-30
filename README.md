# EC2 Auto Restart 

## Description

This project automatically restarts any AWS EC2 instance that shuts down and enters the "STOPPED" state using Eventbridge and Lambda.


## Prerequisites

- **AWS CLI**: This project requires the AWS Command Line Interface (CLI) to interact with AWS services. Ensure you have the AWS CLI installed and configured with the necessary credentials before proceeding. You can follow the instructions on [AWS CLI Installation Guide](https://aws.amazon.com/cli/) for setup.
- **PEM Key**: Please create a .PEM key inside of the AWS console prior to running any Terraform commands. Reference the key with your desired name in the EC2 instance resource block.
- **Custom Configuration Recommendation**:
   - It's recommended to create a `variables.tf` file to manage your configurations. While this project does not include a `variables.tf` file, creating one will allow you to customize various settings to match your environment. Be aware that certain configurations like subnets are specific to the original environment and may not work in your environment without modification. You'll need to specify your own configurations to match your AWS setup.
- **Terraform Installation**:
   - Before running any Terraform commands, ensure that you have Terraform installed on your machine. You can download and install Terraform from [Terraform's official website](https://www.terraform.io/downloads.html).



## Usage instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ec2-auto-restart-tf.git
   cd ec2-auto-restart-tf
2. **Initialize Terraform**:
   ```bash
   terraform init
3. **Apply your TF file**:
   ```bash
   terraform apply
4. **Cleaning up resources**
   ```bash
   terraform destroy

