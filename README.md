# mc-server

Luke and Mateo's Minecraft Server. To deploy yourself just follow all the instructions below *carefully*.

## Aws Setup

1. Create a [**Key Pair**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair).

## Terraform Setup

1. [Install terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. [Install aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. Run `aws configure`. Follow instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
   1. Set your access keys and region, default output format can be json.
4. Run `terraform init` to initialize local settings
5. Import the key pair from aws. `terraform import aws_key_pair.mc_auto_key_pair key` where key is the name of the key you downloaded in aws set up.
   1. You can see possible key names using `aws ec2 describe-key-pairs | jq '.KeyPairs[].KeyName'`

## Server Deploy

1. set the variables in `terraform.tfvars`. Descriptions of these variables can be found in `variables.tf`
2. Run `terraform apply`

## Server Shutdown  
**WARNING THIS LOSES DATA**
1. Run `terraform destroy`

## Useful Terraform Commands 

`terraform [cmd]`

- `plan` - create an execution plan and display it, doesn't affect resources.
- `apply` - apply changes so that resources reflect configuration
- `show` - show the resource state after apply. You can get instance ids.
- `destroy` - destroy all resources in a terraform configuration.

