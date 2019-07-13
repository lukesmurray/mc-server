# mc-server

Luke and Mateo's Minecraft Server. To deploy yourself just follow all the instructions below *carefully*.

# Server Setup

## Aws Setup

1. Create a [**Key Pair**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair).

## Terraform Setup

1. [Install terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. [Install aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. [Install serverless](https://serverless.com/framework/docs/getting-started/)
4. Run `aws configure`. Follow instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
   1. Set your access keys and region, default output format can be json.
5. Run `terraform init` to initialize local settings
6. Import the key pair from aws. `terraform import aws_key_pair.mc_auto_key_pair key` where key is the name of the key you downloaded in aws set up.
   1. You can see possible key names using `aws ec2 describe-key-pairs | jq '.KeyPairs[].KeyName'`

## Server Deploy

1. set the variables in `./mc-server/terraform.tfvars`. Descriptions of these variables can be found in `./mc-server/variables.tf`
2. Run `./deploy.sh`
3. Endpoint is printed out or can be found by running `sls info` from within the `mc-lambda` directory.

## Server Shutdown  
**WARNING THIS LOSES DATA**
1. Run `./destroy.sh`

## Useful Terraform Commands 

`terraform [cmd]`

- `plan` - create an execution plan and display it, doesn't affect resources.
- `apply` - apply changes so that resources reflect configuration
- `show` - show the resource state after apply. You can get instance ids.
- `destroy` - destroy all resources in a terraform configuration.

