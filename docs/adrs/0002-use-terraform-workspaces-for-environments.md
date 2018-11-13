# 2. Use Terraform Workspaces for Environments

Date: 2018-11-13

## Status

Accepted

## Context

There are two primary patterns of use when managing multiple environments (staging, prod, etc) in Terraform. The first is to use multiple directories--one for each environment. This has the advantage of being explicit, with an associated cost of repeated TF configuration. The second alternative uses TF workspaces to switch between environments. This option appears to be [recommended](https://www.terraform.io/docs/enterprise/guides/recommended-practices/part1.html#one-workspace-per-environment-per-terraform-configuration) by Terraform. There's a bit more magic involved, but more config reuse.

Both options could be made to work; general consensus does not clearly call for one or the other, as it seems to heavily depend on the organizational structure, and the size and complexity of your infrastructure.

## Decision

Use workspaces to manage multiple environments. We may wish to reevaluate after a certain time period to ensure our decision is working.

## Consequences

Most resources in AWS will be named by workspace (e.g. `carbon-staging`). Until we have automated TF change deployment it will be up to the engineer to manually switch workspaces.
