# IASC DIPOnline

This folder contains AWS resources needed for the deployment of the DIPOnline folder for IASC

### What's created?:
* An S3 bucket for storing static web files
* An AWS Cloudfront CDN for this S3 Bucket

### Additional Info:
* This is using the mitlib wildcard certificate.
* Files are uploaded to the S3 Bucket manually.
* Eventually this bucket should be attached to Archivematica which will manage the file upload process.
* This will allow static content to be displayed on libraries.mit.edu when it migrates to a cloud provider.
