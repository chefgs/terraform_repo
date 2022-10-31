# Amazon Cloudfront Content Distribution Network

## Context Setting
Content Distribution Network or Content Delivery Network  (or CDN in short) is important while hosting any websites and plays important role in reducing the end user latency time, while accessing a website.

There are many CDN tools and technologies are available and AWS has it's own service for CDN. It is called as **AWS CloudFront**

In this blog, we will see the concepts of CDN and specific about implementing AWS CloudFront using Terraform

## What is CDN?
CDN is a set of servers located across various locations in Globe, forming a Global netwrok used to distribute or deliver the static or dynamic websites. Using the linked network of servers it speeds up the webpage loading for data-heavy applications.

## Why CDN is important
As per the AWS Docs for CDN
> The primary purpose of a content delivery network (CDN) is to reduce latency, or reduce the delay in communication created by a network's design. Because of the global and complex nature of the internet, communication traffic between websites (servers) and their users (clients) has to move over large physical distances. The communication is also two-way, with requests going from the client to the server and responses coming back.

## Amazon CloudFront Arguments
- origin 
  - s3_origin (typical location to store cdn files)
  - custom_origin (other site storage options or it can be another s3 bucket)
- logging_config
- default_cache_behavior (Default CDN cache behaviour)
- ordered_cache_behavior (Cache behaviour if default fails)