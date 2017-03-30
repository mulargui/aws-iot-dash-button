#AWS secrets
export AWS_ACCESS_KEY_ID=12345678901234567890
export AWS_SECRET_ACCESS_KEY=1234567890123456789012345678901234567890
export AWS_ACCOUNT_ID=123456789012
export AWS_DEFAULT_REGION=us-west-1
export AWS_DEFAULT_OUTPUT="text"

#SNS 
export SNS_TOPIC_NAME=NotifyMe
export SNS_EMAIL=contact@domain.com

#IOT
export IOT_THING=DashButton
export IOT_TYPE=${IOT_THING}Type
export IOT_DESC="A software app that mimics AWS IoT dash button hardware"
export IOT_POLICY=${IOT_THING}Policy
export IOT_RULE=ClickReceived
export IOT_EVENT=Click
export IOT_EV_DESC="What to do when we receive a click from our software IoT dash button"

#IAM
export IAM_ROLE=${IOT_THING}Role
export IAM_POLICY=${IAM_ROLE}Policy

