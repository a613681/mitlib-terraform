# DATAVERSE

This folder contains the setup and configuration of standalone Dataverse installation.

## Outputs

| Name | Description |
|------|-------------|
| app-public-fqdn | <app_name>\-<label.name>\-<terraform.workspace>\.<domain\> |
| app-private-fqdn | <app_name>\-<label.name>\-<terraform.workspace>\.<domain\> |

## Application setup and deployment notes

* Using zip download from [Dataverse Release](https://github.com/IQSS/dataverse/releases/tag/v5.0)
* [Prerequizites](https://guides.dataverse.org/en/latest/installation/prerequisites.html)
* Solr and PostgreSql Local
* Deployed using dataverse installer python script and provided target dataverse.war
* Re-deployed using redeploy script template
