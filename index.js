
var awsIot = require('aws-iot-device-sdk');

var device = awsIot.device({
	keyPath: process.env.keyPath,
	certPath: process.env.certPath,
	caPath: process.env.caPath,
	clientId: process.env.clientId,
	region: process.env.region,
	debug: true
});

//
// Device is an instance returned by mqtt.Client(), see mqtt.js for full
// documentation.
//
device.on('connect', function() {
	console.log('Connected!');
    //device.subscribe('Click');
	device.publish(process.env.event, JSON.stringify({ID : process.env.clientId, clicked : 'single'}));
	//wait 250 msg till the message is sent
	setTimeout(function() {
		console.log('Message sent!');
		device.end();
		process.exit();
	}, 250);
});

device.on('message', function(topic, payload) {
	console.log('message', topic, payload.toString());
});
	
device.on('close', function() {
	console.log('close');
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
