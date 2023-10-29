# EC2 Auto Restart 

## Description

This project automatically restarts any AWS EC2 instance that shuts down and enters the "STOPPED" state using Eventbridge and Lambda.

## Prerequisites

- **AWS CLI**: This project requires the AWS Command Line Interface (CLI) to interact with AWS services. Ensure you have the AWS CLI installed and configured with the necessary credentials before proceeding. You can follow the instructions on [AWS CLI Installation Guide](https://aws.amazon.com/cli/) for setup.
- **PEM Key**: Please create a .PEM key inside of the AWS console prior to running any terraform commands. Reference the key with your desired name in the EC2 instance resource block.
- **Terraform Initialization and Apply**:
   - Before running any Terraform commands, ensure that you have Terraform installed on your machine. You can download and install Terraform from [Terraform's official website](https://www.terraform.io/downloads.html).
   - Initialize Terraform in your project directory:
     ```bash
     terraform init
     ```
   - Apply the Terraform configurations:
     ```bash
     terraform apply
     ```

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ec2-auto-restart.git
   cd ec2-auto-restart

