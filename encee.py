import json


def filetest():
    try:
        f = open('token.json')
        f.close()
        return 1
    except:
        return 2


file_exists = filetest()


if file_exists == 1:
    try:
        with open('token.json', 'r') as file:
            data = json.load(file)
        print("AWS_SECRET_ACCESS_KEY=" + data["Credentials"]["SecretAccessKey"])
        print("AWS_SESSION_TOKEN=" + data["Credentials"]["SessionToken"])
        print("AWS_ACCESS_KEY_ID=" + data["Credentials"]["AccessKeyId"])
    except:
        exit(1)
