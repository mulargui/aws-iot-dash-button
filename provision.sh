#!/bin/bash -x

#Load AWS secrets and other config
. ./config.sh

#Setup SNS endpoint
aws sns create-topic --name $SNS_TOPIC_NAME
aws sns subscribe --topic-arn arn:aws:sns:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$SNS_TOPIC_NAME --protocol email --notification-endpoint $SNS_EMAIL
#email subscriptions require manual confirmation by email, no shortcut
echo "========================================"
echo "Please approve the subscription by email"
echo "========================================"

#create a role in IAM to access SNS
cat > trust.json <<EOL
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "Service": "iot.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }]
}
EOL
aws iam create-role --role-name $IAM_ROLE --assume-role-policy-document file://trust.json

cat > role.json <<EOL
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": ["sns:Publish"],
        "Resource": ["arn:aws:sns:${AWS_DEFAULT_REGION}:${AWS_ACCOUNT_ID}:${SNS_TOPIC_NAME}"]
    }]
}
EOL
aws iam create-policy --policy-name $IAM_POLICY --policy-document file://role.json
aws iam attach-role-policy --role-name $IAM_ROLE --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/$IAM_POLICY

#create IOT thing with type
#aws iot create-thing-type --thing-type-name $IOT_TYPE --thing-type-properties thingTypeDescription="${IOT_DESC}"
#aws iot create-thing --thing-name $IOT_THING --thing-type-name $IOT_TYPE

#create IOT thing without type
aws iot create-thing --thing-name $IOT_THING

#create certificates
certificatearn=$( aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile "${IOT_THING}-certificate.pem" --public-key-outfile "${IOT_THING}-public.pem.key" --private-key-outfile "${IOT_THING}-private.pem.key" --query certificateArn)

#we save the certificate arn in config to be used for teardown
echo "export certificatearn=${certificatearn}" >> config.sh

#download root CA certificate
curl https://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem > root-CA.crt

#create policy
cat > policy.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action":["iot:*"],
      "Resource": ["*"]
  }]
}
EOL
aws iot create-policy --policy-name $IOT_POLICY --policy-document file://policy.json

#link all together
aws iot attach-principal-policy --principal $certificatearn --policy-name $IOT_POLICY
aws iot attach-thing-principal --thing-name $IOT_THING --principal $certificatearn

#create the event action
cat > rule.json <<EOL
{
  "sql": "SELECT * FROM '${IOT_EVENT}'",
  "description": "${IOT_EV_DESC}",
  "ruleDisabled": false,
  "actions": [{
      "sns": {
        "targetArn": "arn:aws:sns:${AWS_DEFAULT_REGION}:${AWS_ACCOUNT_ID}:${SNS_TOPIC_NAME}",
        "roleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE}",
        "messageFormat": "RAW"
      }
  }]
}
EOL
aws iot create-topic-rule --rule-name $IOT_RULE --topic-rule-payload file://rule.json
