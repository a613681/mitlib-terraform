# MIT Libraries Terraform Config

This repo contains the main Terraform config for MIT Libraries. Make sure to read through the [ADRs](docs/adrs) first.

## Workspaces

We maintain both `prod` and `stage` copies of most resources. If you have not configured a specific workspace Terraform will use the `default` workspace. Your workspace can be configured by setting the `TF_WORKSPACE` environment variable, or explicitly switching workspaces with the `terraform workspace select` command.

[ADR-2](docs/adrs/0002-use-terraform-workspaces-for-environments.md) provides the rationale for using workspaces.

## Layout

    apps/
      |- app1/
      |- app2/
    global/
      |- global1/
      |- global2/
    shared/
      |- shared1/
      |- shared2/

### The apps Directory

Each application should have its own remote config (tfstate file) stored in an S3 bucket. What constitutes an application is a bit nebulous, but these would typically be custom applications we develop and manage. Ideally, an app will just be a thin layer of TF config with all the heavy lifting provided by modules and global/shared resources. Each app will have multiple workspaces.

### The global Directory

A few resources, e.g. Route53, will only use the `prod` workspace. These global resources should go here.

### The shared Directory

This directory is for resources that may be shared between apps. These might include things like Elasticsearch, Redis, etc. Unlike the `global` directory these resources should have `prod` and `stage` counterparts.

## Naming

Consistent naming is important to being able to maintain a lot of resources. The goal with our naming scheme is to make names that are short and descriptive. Use our [naming module](https://github.com/MITLibraries/tf-mod-name) to generate a name for a resource. This will output a name in the form `<appname>-<workspace>`. The module also provides a set of tags that should be used on any AWS resource that supports tags.
