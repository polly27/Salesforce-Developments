var express	= require('express');
var app		= express();
var pg		= require('pg');
var nforce	= require('nforce');
var fs		= require('fs');

var org = nforce.createConnection({
		clientId: '3MVG9ZL0ppGP5UrAWq2mL6Ce6knQKr4PBYUT4fQATjEtTKgz6WowUdZGeIqlUANiKXG89D1dSfSinYZ_znK1l',
		clientSecret: '4188536809283584595',
		redirectUri: 'https://mega-task-distributor.herokuapp.com/',
		mode: 'single'
	});

app.use(express.logger());

pg.defaults.ssl = true;

app.get('/', function(request, response) {
	response.sendfile('index.html');
});

app.get('/catalog', function(request, response) {
	pg.connect(process.env.DATABASE_URL, function(err, client) {
		if (err) throw err;
		var query = client.query("select Id, Name, Name__c, Description__c, Amount__c, Cost__c from salesforce.Product__c");
		var total = 0;
		query.on("row", function (row, result) { 
   	  	    result.addRow(row);
  	  	    total += row.amount__c * row.cost__c;
   	    });
   	    query.on("end", function (result) {
   	    	response.send({catalog : result.rows, total : total});
	   	});
	});
});

app.get('/top', function(request, response) {
	fs.open('public/top.txt', 'r', function(err, fd) {
		if(err && err.code === "ENOENT") {
		    console.error('\'public/top.txt\' does not exist');
		    return;
		} else if(err) {
		   	throw err;
		}
		var content = fs.readFileSync('public/top.txt','utf8');
		console.log('top.txt content: ' + content);
		response.send(content);
	});
});

app.post('/top', function(request, response) {
	var body = [];
	request.on('data', function(chunk) {
	  	body.push(chunk);
	}).on('end', function(err) {
	  	body = Buffer.concat(body).toString();
	  	console.log("Post data from shop: " + body);
	  	response.send('Top successfully accepted.');
	  	fs.exists('public/top.txt', function (exists) {
		  	if (exists) {
			    fs.writeFileSync('public/top.txt', body, 'utf-8');
		  		console.log('New top.txt content: ' + body);
				org.authenticate({
					  username: 'factory@codeswat.com',
					  password: 'jaabutnmqaz1010' + 'S9hYKNhwCE0c5ysQT3QkVMFJh'
					}, function(err, resp){
					    if (err) throw err;
					    console.log('Successfully logged in Factory! Cached Token: ' + org.oauth.access_token);
					    body = JSON.stringify({top : body});
					    org.apexRest({ uri : '/top', method : 'POST', body : body}, function(err, resp) {
					    	if(err) throw err;
						    console.log('Post to factory success:  ' + resp);
					    });
				});
			}
		});
	});
});

app.post('/products', function(request, response) {
	var body = [];
	request.on('data', function(chunk) {
	  	body.push(chunk);
	}).on('end', function(err) {
	  	body = Buffer.concat(body).toString();
	  	console.log("Body from factory: " + body);
		response.send('Products successfully accepted.');
		pg.connect(process.env.DATABASE_URL, function(err, client) {
			if (err) throw err;
			body = JSON.parse(body);
			console.log('Parsed products: ' + body);
			body.forEach(function(item){
				client.query(
					'select * from salesforce.Product__c where Name__c = $1 limit 1',
					[item.Name__c], 
					function (err, result) {
						console.log("factory product: " + JSON.stringify(item));
					    if (err) throw err;
					    if(result.rows.length == 1) {
					    	client.query(
						 		'update salesforce.Product__c set Description__c = $1, Amount__c = $2, Cost__c = $3 where Name__c = $4 returning *',
						 		[item.Description__c, result.rows[0].amount__c + item.Amount__c, item.Cost__c, item.Name__c],
						 		function(err, result) {
						 			if (err) throw err;
									console.log("row updated: " + JSON.stringify(result.rows[0]));
					 		});
					    } else {
						 	client.query(
						 		'insert into salesforce.Product__c (Name__c, Description__c, Amount__c, Cost__c) values ($1,$2,$3,$4) returning *',
						 		[item.Name__c, item.Description__c, item.Amount__c, item.Cost__c],
						 		function(err, result) {
						 			if (err) throw err;
									console.log("row inserted with id: " + JSON.stringify(result.rows[0]));
					 		});
					    }
				});
			});			
		});
	});
	
});

var port = process.env.PORT || 5000;
app.listen(port, function() {
  	console.log("Listening on " + port);
});

