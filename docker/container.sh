sudo docker stop AWSIOT
sudo docker rm AWSIOT
sudo docker run -ti --name AWSIOT -v /vagrant/apps/aws-iot-dash-button:/myapp awsiot /bin/bash