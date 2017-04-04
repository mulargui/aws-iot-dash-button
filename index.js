
//https://github.com/aws/aws-iot-device-sdk-js/blob/master/README.md#device

var awsIot = require('aws-iot-device-sdk');

var device = awsIot.device({
	keyPath: process.env.keyPath,
	certPath: process.env.certPath,
	caPath: process.env.caPath,
	clientId: process.env.clientId,
	region: process.env.region,
	debug: true
});


device.on('connect', function() {
	console.log('Connected!');
	
	//we subscribe to our own event to get confirmation of delivery
    device.subscribe('Click');
	
	//send a click!
	device.publish(process.env.event, JSON.stringify({ID : process.env.clientId, clicked : 'single'}));
});

device.on('message', function(topic, payload) {
	//received confirmation of click sent
	console.log('message', topic, payload.toString());
	
	//end nicely, close the connection
	device.end();
});
	
device.on('close', function() {
	console.log('close');
	
	//ending after the connection is closed
	process.exit(1);
});

device.on('reconnect', function() {
	console.log('reconnect');
});

device.on('offline', function() {
	console.log('offline');
});

device.on('error', function(error) {
	console.log('error', error);
});
