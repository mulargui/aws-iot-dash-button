#!/bin/bash -x

#Load AWS secrets and other config
. ./config.sh

region="${AWS_DEFAULT_REGION}" \
keyPath="./${IOT_THING}-private.pem.key" \
certPath="./${IOT_THING}-certificate.pem" \
caPath="./root-CA.crt" \
clientId="001" \
event="${IOT_EVENT}" \
node index.js

