# DATAVERSE

This folder contains the setup and configuration of MIT Dataverse installation of [Harvard Dataverse](https://dataverse.harvard.edu/)

## Infrasturucture created with terraform and configured with ansible

* Dataverse Application - in public subnet, ELB healthcheck 
* Zookeeper 3 nodes - private subnet to be build and configured first
* SolrCloud 2 nodes - private subnet, ELB healthcheck
* RDS - private subnet

## Outputs

| Name | Description |
|------|-------------|
| app-public-fqdn | <app_name>\-<terraform.workspace>\.<domain\> |
| app-private-fqdn | <app_name>\-<terraform.workspace>\.<domain\> |
| zookeeper-private-fqdn |<zookeeper_name\>\-<terraform.workspace>\-\<count>\.<domain\> |
| solr-private-fqdn  | \<solr\>\-<terraform.workspace>\-<count\>\.<domain\> |
| rds-private-fqdn | <app_name>\-<terraform.workspace>\.<domain\> |
| efs-mount-target-solr-fqdn| <app_name>\-<terraform.workspace>\.<domain\> |  
| efs-mount-target-zookeeper-fqdn| <app_name>\-<terraform.workspace>\.<domain\>|

## Application setup and deployment notes
