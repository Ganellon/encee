#!/bin/bash

# unset any previous AWS token environment variables
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_ACCESS_KEY_ID

# remove any old versions of temp.tmp or token.json
if [ -e temp.tmp ]; then
	rm temp.tmp
fi

if [ -e token.json ]; then
  rm token.json
fi

#try to determine MFA ARN from config file, otherwise prompt for ARN
if [ -e ~/.encee/config ]; then
	echo "Reading the ARN for your MFA device..."
	read MFA_ARN < ~/.encee/config
else
	echo "Config file not located. Please enter the ARN for your MFA device:"
	read MFA_ARN
fi

# make sure the ARN isn't a null or empty string
if [ -z "$MFA_ARN" ]; then
	echo "Invalid MFA ARN. Unable to continue."
	return 2> /dev/null
fi

# prompt for the number of seconds
echo "Please enter the number of seconds for which the temporary credentials will be valid for AWS CLI:"
echo "(minimum = 900 seconds (15 mintues), max = 129600 seconds (36 hours), default = 3600 (1 hour))" 
read VALID_SECONDS

if [ -z "$VALID_SECONDS" ]; then
	echo "Default time value -- 3600 seconds."
	VALID_SECONDS=3600
fi

# make sure this is a number value
case $VALID_SECONDS in
	''|*[!0-9]*)
		echo "Invalid time value. Unable to continue."
		return 2> /dev/null ;;
esac

# make sure it's within the min and max limits for temp credentials
if [ "$VALID_SECONDS" -lt 900 ] || [ "$VALID_SECONDS" -gt 129600 ]; then
	echo "Invalid time value. Unable to continue."
	return 2> /dev/null
fi

# prompt for the token displayed on the MFA device
echo "Please enter the token code on your MFA Device:"
read TOKEN_CODE

# make sure the token code is numeric
case $TOKEN_CODE in
	''|*[!0-9]*)
		echo "Invalid token code. Unable to continue."
		return 2> /dev/null ;;
esac

# ensure the token code is exactly six digits
if [ ${#TOKEN_CODE} -ne 6 ]; then
	echo "Token code must be six digits. Unable to continue."
	return 2> /dev/null
fi

# make the call to AWS STS to request temporary credentials
echo "Fetching temporary credentials from AWS STS..."
aws sts get-session-token --serial-number $MFA_ARN --duration-seconds $VALID_SECONDS --token-code $TOKEN_CODE > token.json

# check the return code from the AWS STS call; 0 = success
if [ $? -ne 0 ]; then
	echo "There was an error while requesting credentials from AWS. Unable to continue."
	return 2> /dev/null
fi

# parse the returned JSON to retreive the values
echo "Parsing JSON..."
python encee.py > temp.tmp

# check the return code from encee.py; 0 = success, 1 = fail
if [ $? -eq 1 ]; then
	echo "Unable to parse token.json. Unable to continue."
	return 2> /dev/null
fi

# read all the rows in the temp.tmp and export them to environment variables
echo "Setting enviroment variables..."
while read TEMP
do
	export "$TEMP"
	echo "$TEMP"
done < temp.tmp

# remove the temporary files
echo "Cleaning up temporary files..."
rm token.json
rm temp.tmp

echo "Finished"
