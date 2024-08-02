#! /bin/bash

# list ec2 instances (refer to the aws cli docs for such examples)
echo "ID and State of EC2 Instances"
aws ec2 describe-instances --query 'Reservations[].Instances[].{InstanceID:InstanceId,State:State.Name}' --output json

# list IAM Users (refer to the aws cli docs for such examples)
echo "List of IAM users"
aws iam list-users --query 'Users[].{Name:UserName,id:UserId}' --output json


<<notes
    --output : this flag is used to format the style of the output

    --query : this flag is used to filter response data using JMESPath query language. Checkout https://jmespath.org/tutorial.html to clear any doubt regarding the query
notes