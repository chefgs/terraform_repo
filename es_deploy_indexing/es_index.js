var AWS = require('aws-sdk');

var region = 'us-west-2'; // e.g. us-west-1
var domain = 'search-domainName-w5***********i.us-west-2.es.amazonaws.com'; // Modify the ES domain URL - e.g. search-domain.region.es.amazonaws.com
var index = 'es-node-test';
var type = 'node-type';
var id = '1'; // Change the ID value and add more index data
/*
var json = {
  "title": "Moneyball",
  "director": "Bennett Miller",
  "year": "2011"
}
*/
var json = require('./feed.json');

indexDocument(json);

function indexDocument(document) {
  var endpoint = new AWS.Endpoint(domain);
  var request = new AWS.HttpRequest(endpoint, region);

  request.method = 'PUT';
  request.path += index + '/' + type + '/' + id;
  request.body = JSON.stringify(document);
  request.headers['host'] = domain;
  request.headers['Content-Type'] = 'application/json';
  request.headers['Content-Length'] = request.body.length;

  var credentials = new AWS.EnvironmentCredentials('AWS');
  var signer = new AWS.Signers.V3(request, 'es');
  signer.addAuthorization(credentials, new Date());

  var client = new AWS.HttpClient();
  client.handleRequest(request, null, function(response) {
    console.log(response.statusCode + ' ' + response.statusMessage);
    var responseBody = '';
    response.on('data', function (chunk) {
      responseBody += chunk;
    });
    response.on('end', function (chunk) {
      console.log('Response body: ' + responseBody);
    });
  }, function(error) {
    console.log('Error: ' + error);
  });
}
