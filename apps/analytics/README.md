## Search Analytics 

This folder contains the configuration for deploying of the [matomo analytics docker container](https://hub.docker.com/_/matomo) to AWS Fargate behind an application load balancer.

#### What's created?:
* An ECR repo for storing Docker images
* Route53 record to an ALB with a .mitlib.net name
* ALB target group to direct ingress traffic from our ALB to the container(s)
* ECS cluster to run our Fargate task
* Fargate task to run matomo container
* Fargate service to excecute the task
* IAM task excecution role
* EFS for container persistent storage
* RDS to store matomo database



#### Additional notes:
* 

## Outputs
| Name | Description |
|------|-------------|
| deploy\_user | Name of the IAM deploy user |

