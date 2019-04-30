# Document-services

This folder contains the configuration for the [Document-services](https://github.mit.edu/mitlibraries/docs) CakePHP ordering system. This is configured to use a single instance Elastic Beanstalk environment and an RDS database.

### What's created?:
* Single instance Elastic Beanstalk environments configured for PHP
* MySQL RDS Databases
* S3 Buckets for storing manually generated .mit.edu certificates for use with the application


### Additional Info:
* SSH has been configured to use Matt's key by default. (If additional keys are needed, it may be easiest to do this through the .ebextensions folder in the app configuration)
* To SSH into the instance, make sure to use the default `ec2-user` (e.g. `ssh ec2-user@document-services.mit.edu`)
