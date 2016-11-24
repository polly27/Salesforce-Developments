var express	= require('express');
var app		= express();
var braintree = require("braintree");

var gateway = braintree.connect({
	environment: braintree.Environment.Sandbox,
	merchantId: "gwhwjzqk4h9cwst9",
	publicKey: "dbhtc6b7npxxdn5d",
	privateKey: "b6176ff51604a3ab9274faae474b8984"
});

app.use(express.logger());

app.get("/client_token", function (req, res) {
	console.log('***** getting client token *******');
	gateway.clientToken.generate({}, function (err, response) {
		console.log(response.clientToken);
		res.send(response.clientToken);
	});
});

app.post("/paypal_checkout", function (req, res) {
	console.log('***** paypal_checkout *******');
	var body = [];
	req.on('data', function(chunk) {
	  	body.push(chunk);
	}).on('end', function(err) {
	  	body = Buffer.concat(body).toString();
	  	console.log("Post data: " + body);
	  	body = JSON.parse(body);
		var saleRequest = {
		  amount: body.amount,
		  paymentMethodNonce: body.nonce,
		  orderId: "Mapped to PayPal Invoice Number",
		  options: {
		    paypal: {
		      customField: "PayPal custom field",
		      description: "Description for PayPal email receipt",
		    },
		    submitForSettlement: true
		  }
		};

		gateway.transaction.sale(saleRequest, function (err, result) {
		  if (err) {
		  	console.log("Error:  " + err);
		    res.send("Error:  " + err);
		  } else if (result.success) {
		  	console.log("Success! Transaction ID: " + result.transaction.id);
		    res.send("Success! Transaction ID: " + result.transaction.id);
		  } else {
		  	console.log("Error:  " + result.message);
		    res.send("Error:  " + result.message);
		  }
		});
	});
});

app.post("/credit_card_checkout", function (req, res) {
	console.log('***** credit_card_checkout *******');
	var body = [];
	req.on('data', function(chunk) {
	  	body.push(chunk);
	}).on('end', function(err) {
	  	body = Buffer.concat(body).toString();
	  	console.log("Post data: " + body);
	  	body = JSON.parse(body);
	  	var saleRequest = {
		  amount: body.amount,
		  paymentMethodNonce: body.nonce,
		  options: {
		    submitForSettlement: true
		  }
		};
		gateway.transaction.sale(saleRequest, function (err, result) {
		  if (err) {
		  	console.log("Error:  " + err);
		    res.send("Error:  " + err);
		  } else if (result.success) {
		  	console.log("Success! Transaction ID: " + result.transaction.id);
		    res.send("Success! Transaction ID: " + result.transaction.id);
		  } else {
		  	console.log("Error:  " + result.message);
		    res.send("Error:  " + result.message);
		  }
		});
	});
});

var port = process.env.PORT || 5000;
app.listen(port, function() {
	console.log("Listening on " + port);
});

