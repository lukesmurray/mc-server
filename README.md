# mc-server

Luke and Mateo's Minecraft Server. Runs [itzg/minecraft-server](https://github.com/itzg/dockerfiles/tree/master/minecraft-server). Has automatic backups and loading from s3. In order to reduce costs the server turns itself off if no one is playing for 12 minutes. A passsword protected website hosted on Amazon Lambda can be used to turn the server back on.

To deploy yourself just follow all the instructions below _carefully_.

# Server Setup

## Aws Setup

1. Create a [**Key Pair**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair).
   - `aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem`
   - `chmod 400 MyKeyPair.pem`
2. Copy the key pair to this folder.

## Terraform Setup

1. [Install terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. [Install aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. [Install serverless](https://serverless.com/framework/docs/getting-started/)
4. Run `aws configure`. Follow instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
   1. Set your access keys and region, default output format can be json.
5. Run `terraform init mc-server` to initialize local settings
6. Import the key pair from aws. `terraform import -config=mc-server aws_key_pair.mc_auto_key_pair MyKeyPair` where MyKeyPair is the name of the key you downloaded in aws set up.
   1. You can see possible key names using `aws ec2 describe-key-pairs | jq '.KeyPairs[].KeyName'`

## Optional Bucket Import

1. Run `terraform import -config=mc-server aws_s3_bucket.mc_auto_bucket your-bucket-name`

## Server Deploy

1. set the variables in `./terraform.tfvars`. Descriptions of these variables can be found in `./mc-server/variables.tf`
2. Run `./deploy.sh`
3. Endpoint is printed out or can be found by running `./url.sh`.

## Server Shutdown (Safe Mode Data Preserved)

This will destroy any compute instances but keep back ups of your world in the bucket specified by bucket name. You may be charged for these. You will see an error, bucket not empty but all other resources will have been destroyed.

1. Run `./destroy.sh`

## Server Shutdown (DANGER MODE)

This will destroy compute instances and the bucket.

1. Go into `server.tf` and change `force_destroy` in `mc_auto_bucket` to `true`.
2. Run `terraform apply --auto-approve mc-server`
3. Run `./destroy.sh`

## S3 Bucket

The server automatically performs versioned backups of the [server data directory](https://github.com/itzg/dockerfiles/tree/master/minecraft-server#attaching-data-directory-to-host-filesystem) to `s3://<your_bucket_name>/mc-auto-backups`. If you have an existing data directory from [itzg/minecraft-server](https://github.com/itzg/dockerfiles/tree/master/minecraft-server) you can use `aws s3 sync <your_data_directory> s3://<your_bucket_name>/mc-auto-backups` to pass the data to the server before deployment. The server will automatically load your data into the initial world.

## Dockerfile

Feel free to edit the variables in the [docker-compose file](https://github.com/lukesmurray/mc-server/blob/master/mc-server/mc-server-scripts/docker-compose.yml) to customize your server. Variable definitions can be found in the [itzg/minecraft-server readme](https://github.com/itzg/dockerfiles/tree/master/minecraft-server). Do not change the volumes since the mount point is important for backups. Feel free to change the memory limit if you have a smaller or larger instance.

## Upgrading

First download the existing bucket to a local folder. where mc-`mc-auto-bucket` is the name of your s3 bucket from `./terraform.tfvars`.

`aws s3 sync s3://mc-auto-bucket/mc-auto-backups ./mc-server-example`

Next move the world in the folder to your minecraft local save.

`cp -r ./mc-server-example/world /Users/lukemurray/Library/Application Support/minecraft/saves/world`

Now optimize the world in local minecraft. Then copy the world back to
the local save.

`cp -r /Users/lukemurray/Library/Application Support/minecraft/saves/world ./mc-server-example/world`

Sync the local copy back to the bucket

`aws s3 sync ./mc-server-example s3://mc-auto-bucket/mc-auto-backups`

Now destroy and restart the server.

`terraform destroy --auto-approve mc-server`

`./deploy.sh`

## Useful Terraform Commands

`terraform [cmd]`

- `plan` - create an execution plan and display it, doesn't affect resources.
- `apply` - apply changes so that resources reflect configuration
- `show` - show the resource state after apply. You can get instance ids.
- `destroy` - destroy all resources in a terraform configuration.
