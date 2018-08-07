# "Single node ElasticSearch" with Node.JS Index deployed in AWS.

 <h2>
   Important note & Pre-requisite
  </h2>
<h3>
  Installation of required AWS packages
  </h3>
  <a href="https://docs.aws.amazon.com/cli/latest/userguide/installing.html">AWS CLI</a> and <a href="https://docs.aws.amazon.com/cli/latest/reference/configure/">Configure CLI</a><br>
  <a href="https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/installing-jssdk.html">AWS JS SDK<a><br>

- Terraform config needs, AWS secret, access and account ID to work. <br>
- Node.js needs temporary keys for AWS secret, access and token. <br>

Run the below mentioned AWS STS CLI command to generate temporary AWS access, secret and session key.<br>
`aws sts get-session-token`<br>
Add the generated temporary key values into Windows Envrionment variable<br>
export AWS_ACCESS_KEY_ID="your-access-key"<br>
export AWS_SECRET_ACCESS_KEY="your-secret-key"<br>
export AWS_SESSION_TOKEN=""your-session-token"<br>
 
 <h2>
  Install and Configure Terraform
  </h2>
  Refer here <a href="https://www.terraform.io/downloads.html">for installing terraform</a><br>
  Add terraform executable path to ENV variables

<h2>
Source File Details
</h2>
aws_single_es.tf - Terraform config file<br>
es_index.js - Node.js source for adding index to ES<br>
feed.json - Json inputs to be added as index<br>
 
 <h2>
  Steps to spin up the ES in AWS 
  </h2>
 1. Clone the repository terraform_repo<br>
 2. cd terraform_repo<br>
 3. Open the .tf file and edit/save the variable section to add the AWS access key, secret key and account id.<br>
 4. Run the below commands from the path where .tf is located to spin up Elastic search single node cluster,<br>
<i>
 terraform init<br>
 terraform apply<br></i>
 type "yes" when prompted<br>
 5. Proceed to create ES index, after the ElasticSearch creation is completed.<br>

 <h2>
 Setup ElasticSearch Index using node.js
 </h2>
 1. Pick-up the ElasticSearch domain name URL from AWS console or AWS CLI command<br>
 2. Execute the node.js code using below command<br>
 <i>node es_index.js</i><br>
 node.js code will be using the "feed.json" file to feed the index data to ElasticSearch.<br>
 3. If execution is successful the console will show, <i>"201 created"</i><br>
 4. Edit the feed.json file with another data and modify the "var id" value es_index.js file.<br>
 5. Then repeat step 2, to feed another json index search data.
 
 Optionally, we can verify the ElasticSearch domain and added index from AWS console.<br>
 
 <h2>
 Verifying the ElasticSearch and Added Index using ES Query
 </h2>
 1. ElasticSearch index can be tested using the ES domain endpoint and ES search query.<br>
 2. Use the below curl command to test the ES index fed via feed.json<br>
 The sample uses twitter like json response to process using the ES domain we have created above.<br>
 <font face='courier new'>
  curl -XGET 'https://search-gs-demo-es-vjgctwz2jolpvhsmd2iicuj5mu.us-west-2.es.amazonaws.com/es-node-test/_search?pretty=true' -H 'Content-Type: application/json' -d '{"query" : {"match" : { "user": "Dash" }}}'<br><br>
  curl -XGET 'https://search-gs-demo-es-vjgctwz2jolpvhsmd2iicuj5mu.us-west-2.es.amazonaws.com/es-node-test/_search?pretty=true' -H 'Content-Type: application/json' -d '{"query" : {"match" : { "user": "John" }}}'<br>
</font>
<h3>
ElasticSearch Index Query Output
</h3> 
The sample query output of the ES indexing search will return output as below,<br>
<blockquote>
$ curl -XGET 'https://search-gs-demo-es-vjgctwz2jolpvhsmd2iicuj5mu.us-west-2.es.amazonaws.com/es-node-test/_search?pretty=true' -H 'Content-Type: application/json' -d '{"query" : {"match" : { "user": "Smith" }}}'<br><br>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   562  100   519  100    43    519     43  0:00:01  0:00:01 --:--:--   473{
  "took" : 6,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "node-test7",
        "_type" : "node-type",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "user" : "Smith",
          "post_date" : "2009-11-15T14:12:12",
          "message" : "Another tweet like sample for Smith"
        }
      }
    ]
  }
}
</blockquote>

<h2>
Alerts and Monitoring
</h2>
- AWS has the facility to monitor the ElasticSearch service through Cloudwatch alerts.<br>
- Also the query status can be monitored ElasticSearch page via AWS console.<br>
- <a href="https://aws.amazon.com/blogs/database/get-started-with-amazon-elasticsearch-service-set-cloudwatch-alarms-on-key-metrics/">AWS Cloudwatch basics and Setup alarm</a> for ElasticSearch<br>
- List of <a href="https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html">AWS Cloudwatch</a> Alert types for ES<br>

 
<h2>
Resolving issues while executing node.js
</h2> 
Error 1:<br>
Error: Hostname/IP doesn't match certificate's altnames: "Host: https. is
 not in the cert's altnames: DNS:*.us-west-2.es.amazonaws.com"<br>
Root cause<br>
It is due to the wrong representation of ES domain in js variable<br>
Applied fix<br>
Domain value Should NOT be having any slash '/' (for ex: e.g. search-domain.region.es.amazonaws.com)<br><br>

Error 2: AWS creds crypto error<br>
Root Cause: AWS access, secret and session key not set properly<br>
Applied fix<br>
Run the below mentioned AWS STS CLI command to generate temporary AWS access, secret and session key.<br>
Add those temporary key values into Windows Envrionment variable<br>
export AWS_ACCESS_KEY_ID="your-access-key"<br>
export AWS_SECRET_ACCESS_KEY="your-secret-key"<br>
export AWS_SESSION_TOKEN=""your-session-token"<br><br>
  
<h2>
  Other references
  </h2>
  <a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/full-text-queries.html"> ES Query reference </a><br>
  <a href="https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-indexing-programmatic.html#es-indexing-programmatic-node">Node.js index sample</a><br>
  <a href="https://github.com/elastic/elasticsearch"> Github ElasticSerch repo</a><br>
