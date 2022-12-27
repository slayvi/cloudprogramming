# Cloud Programming DLBSEPCP01_E
Deploying a Machine Learning Model with Terraform as Infrastructure as a Code (IaC) on Amazon Web Services (AWS)



## Prerequieries
1. Linux Distribution // Windows Subsystem for Linux (WSL)
First, make sure you have a Linux Distribution to run the IaC template. If you're working with Windows, check the [Documentation on WSL](https://learn.microsoft.com/en-us/windows/wsl/) to set up a WSL.

2. AWS Account 
You will have to create an account at AWS to use this template. For further information, please visit the [official AWS website](https://aws.amazon.com/).
Make sure to also download the AWS Command Line Interface (AWS CLI). 

3. Terraform
Next, you need to make sure Terraform runs on your PC. For downloading and setting up the tool please visit the [official website](https://www.terraform.io/).

4. Docker 
Last, you will need Docker on your PC. For download and documentation, please check the [official website](https://www.docker.com/).

After following the above mentioned steps, you're good to go to download and run the terraform script. 


## 

TODO

### start docker
### linux


$ terraform plan -target=aws_s3_bucket.backend -out=/tmp/tfplan
$ terraform apply /tmp/tfplan
