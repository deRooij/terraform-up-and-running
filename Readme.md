# Getting started

### Access your aws account using console

If you don't already have an AWS account go to aws.amazon.com to sign up.\
This will create you as root user but for security we want to use IAM users with specific rights.

#### Create IAM user

Go to the IAM console and create a new user, generate a new access key and save it to your local machine.\
To run all examples add the following Policies to this IAM user:

- AmazonEC2FullAccess
- AmazonS3FullAccess
- AmazonDynamoDBFullAccess
- AmzonRDSFullAccess
- CloudWatchFullAccess
- IAMFullAccess

#### Use IAM user

Make sure to have [terraform installed](https://www.terraform.io/downloads)\
To use the created credentials we set them as environment variables by running the following commands:

```
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```
