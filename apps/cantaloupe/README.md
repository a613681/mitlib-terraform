## Cantaloupe IIIF image server

This folder contains the configuration for deploying our version of the [Cantaloupe Image Server](https://github.com/MITLibraries/docker-cantaloupe) to AWS Fargate behind an application load balancer.

#### What's created?:
* An ECR repo for storing Docker images
* Route53 record to an ALB with a .mitlib.net name
* ALB target group to direct ingress traffic from our ALB to the Cantaloupe container(s)
* ECS cluster to run our Fargate task
* Fargate task to run our Cantaloupe container
* Two S3 Buckets (1 for JP2 image storage, 1 for image caching)
* Two IAM users/keys (1 to read from image bucket, 1 to read/write to/from cache bucket)

#### Additional notes:
* We are currently using the OpenJpeg Processor while we sort out Kakadu licensing
* The `stage` environment is restricted to MIT access only (18.0.0.0/9)
* Admin web GUI is disabled in the `prod` environment
