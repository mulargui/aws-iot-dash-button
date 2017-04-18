FROM ubuntu:latest

# Install node.js, and supplementary programs
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && apt-get -y -qq install \
	curl \
	nodejs \
	nodejs-legacy \
	npm \
	awscli
	
RUN npm install --save \
	aws-iot-device-sdk \
	aws-sdk

ENV NODE_PATH=/usr/local/lib/node_modules

# By default, simply start the app
#CMD exec ../run.sh
