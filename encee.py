import json
with open('token.json', 'r') as file:
    data = json.load(file)

print("AWS_SECRET_ACCESS_KEY=" + data["Credentials"]["SecretAccessKey"])
print("AWS_SESSION_TOKEN=" + data["Credentials"]["SessionToken"])
print("AWS_ACCESS_KEY_ID=" + data["Credentials"]["AccessKeyId"])
