var fs = require('fs');
var headers = require('header-metadata');

var sm = require('service-metadata');
sm.mpgw.skipBackside = true;

//var size = new Number(2**32);
//var buffer = new ArrayBuffer(size);

console.error("Debug log message");

session.output.write("Debug log message");
