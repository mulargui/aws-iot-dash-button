#!/bin/bash -x

#Load AWS secrets and other config
. ./config.sh

#extract the certid from the certarn
certid=$(echo $certificatearn | cut -f 6 -d ':' | cut -c 6-)

#Tear down
rm root-CA.crt ${IOT_THING}-certificate.pem ${IOT_THING}-public.pem.key ${IOT_THING}-private.pem.key
rm trust.json role.json policy.json rule.json

aws iot delete-topic-rule --rule-name $IOT_RULE
aws iot detach-thing-principal --thing-name $IOT_THING --principal $certificatearn
aws iot detach-principal-policy --policy-name $IOT_POLICY --principal $certificatearn
aws iot delete-policy --policy-name $IOT_POLICY
aws iot update-certificate --certificate-id $certid --new-status INACTIVE
aws iot delete-certificate --certificate-id $certid
aws iot delete-thing --thing-name $IOT_THING

#delete thing type if used
#aws iot deprecate-thing-type --thing-type-name $IOT_TYPE
#need to wait 5 mins to delete a deprecated thing type
#sleep 320
#aws iot delete-thing-type --thing-type-name $IOT_TYPE

aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/$IAM_POLICY
aws iam delete-policy --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/$IAM_POLICY
aws iam delete-role --role-name $IAM_ROLE


subscriptionarn=$(aws sns list-subscriptions-by-topic --topic-arn arn:aws:sns:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$SNS_TOPIC_NAME --query 'Subscriptions[0].SubscriptionArn')
aws sns unsubscribe --subscription-arn $subscriptionarn
aws sns delete-topic --topic-arn arn:aws:sns:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:$SNS_TOPIC_NAME
