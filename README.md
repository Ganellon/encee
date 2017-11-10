# noob-cop
## Background
After reading about a number of incidents related to AWS and the theft of credentials, I wanted to make a utility that makes it easier (and therefore more likely) for users to require MFA for CLI so that theft of user credentials doesn't result in fraudulent charges to one's AWS account.
The biggest obstacle to adoption of these practices is the AWS documentation; it is incomplete and inaccurate. After some hair pulling, I finally got things working and want to share these discoveries with others.

## Solution Files
* IP / CIDR Restriction Policy JSON doc for AWS
* MFA Requirement Policy JSON doc for AWS
* encee config file - to store the ARN of your MFA device
* encee bash script - to make OS environment changes that persist in the shell
* encee python script - to read the JSON returned by the AWS STS request

## Setup
1. Restriction policies are created on the AWS account, manually or with encee config
    1. You can optionally have a new group named 'encee' added to your AWS account, and the included policies will be applied automatically to the newly created group
1. Ensure that MFA is enabled for every IAM user account that you want to secure. It's best practices, and without it, once the policy is applied, users without MFA will not be able to use AWS CLI.
1. Manually add AWS IAM User accounts to the 'encee' group (or whatever group you created).
1. Manually edit the IP Restriction Policy to reflect your IP address or CIDR block. All others are denied.
1. Copy the arn of the MFA device you intend to use.
1. Run the encee config python script to persist your MFA ARN in ~/.encee/config, or manually edit the file and paste the ARN of the MFA device for the user.

## Usage
1. `source` the encee bash script, and provide your MFA token and desired validity duration when prompted

## How it works
1. encee bash (or Posh) script requests temp credentials from AWS STS; you specify validity duration in seconds
1. AWS STS returns JSON that contains the temporary credentials
    * Secret Access Key
    * Access Key ID
    * Session Token
    * Expiration Time
1. Output is redirected to ./token.json
1. encee python is called by bash; it reads the token.json file and outputs values to ./token.tmp
1. bash reads ./token.tmp and calls EXPORT to create / update the AWS environment variables and supply their values
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
    * `AWS_SESSION_TOKEN`
1. AWS CLI uses the provided temporary security token to authenticate any API calls; no MFA = no access
