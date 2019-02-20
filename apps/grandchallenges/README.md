# Grand Challenges website

This folder contains AWS resources needed for the deployment of the [Grand Challenges Website](https://github.com/MITLibraries/grandchallenges).

### What's created?:
* An S3 bucket for storing static web files
* An AWS Cloudfront CDN for this S3 Bucket

### Additional Info:
* Grand Challenges is only deployed to the Terraform `prod` workspace
* The grandchallenges.mit.edu certificate was uploaded manually to ACM
* Files were uploaded to the S3 Bucket manually. There is no automated deployment method from the Grand Challenges repo to the S3 bucket. (This was decided to be fine since the site won't be updated, or updated rarely.)
