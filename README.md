# encee
## Background
After reading about a number of incidents related to AWS and the theft of credentials, I wanted to make a utility that makes it easier (and therefore more likely) for users to require MFA for CLI so that theft of user credentials doesn't result in fraudulent charges to one's AWS account.
The biggest obstacle to adoption of these practices is the AWS documentation; it is incomplete and inaccurate. After some hair pulling, I finally got things working and want to share these discoveries with others.

## Solution Files
* IPRestriction.json -- IP / CIDR Restriction Policy doc for AWS
* MFARequired.json -- MFA Requirement Policy doc for AWS
* config.sh -- bash script to automate some of the setup process (optional)
* encee.sh -- encee bash script - to make environment variable changes that persist in the shell
* encee.py -- encee python script - to read the JSON returned by the AWS STS request

## Setup
1. **It is assumed that you have already downloaded the AWS CLI, have downloaded your IAM User Credentials, and have already run AWS CONFIGURE to get your environment set up. DO THAT FIRST!**
1. Restriction policies are created on the AWS account, manually or with config.sh
    * You can optionally have a new group named 'encee' added to your AWS account, and the included policies will be applied automatically to the newly created group. The policies are not in effect until users are added to the encee group.
1. Ensure that MFA is enabled for every IAM user account that you want to secure. It's best practices. Once the **MFA Required** policy is applied, IAM users without MFA will not be able to use AWS CLI.
1. Manually edit the **IP Restriction** Policy to reflect your IP address or CIDR block. All others are denied.
    * IMPORTANT NOTE: Applying the policy to an existing group is effective immediately. Make sure the IP or CIDR block is correct before applying the policy! If the IP or CIDR you supply is incorrect, you will need to login to the AWS Console with your root credentials to make corrections to the IPRestriction Policy before any IAM User accounts will be able to log into the AWS Console or use AWS CLI.
1. Manually add AWS IAM User accounts to the 'encee' group (or whatever group you created).
1. Go to your IAM Users menu, and copy the arn of the MFA device you intend to use.
1. Run the encee config python script to persist your MFA ARN in ~/.encee/config, or manually edit the file and paste the ARN of the MFA device for the user.

## Usage
1. `source encee.sh`
1. Follow the prompts to provide your desired validity duration and MFA Token when prompted

## How it works
1. encee.sh bash script requests temp credentials from AWS STS; you specify validity duration in seconds
1. AWS STS returns JSON that contains the temporary credentials
    * Secret Access Key
    * Access Key ID
    * Session Token
    * Expiration Time
1. Output is redirected to ./token.json
1. encee.py python script reads the token.json file and outputs environment variable values to ./temp.tmp
1. encee.sh reads ./temp.tmp and calls EXPORT to create / update the AWS environment variables and their values
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
    * `AWS_SESSION_TOKEN`
1. AWS CLI uses the provided temporary security token to authenticate any API calls; no MFA = no access
