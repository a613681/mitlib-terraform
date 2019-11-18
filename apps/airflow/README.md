# Airflow

This is our implementation of [Airflow](https://airflow.apache.org/). It's run as a cluster on Fargate. There are several pieces to this. An overview looks like:

```
                 +-----------+
                 |  Airflow  |
                 | Scheduler |--+   +---------------+
                 +-----------+  |   |   Postgres    |
                                +-->|    (RDS)      |
                 +-----------+  |   +---------------+
                 |  Airflow  |--+
                 |  Worker   |  |
                 +-----------+  |   +---------------+
                                +-->|     Redis     |
  +---------+    +-----------+  |   | (Elasticache) |
  | AWS ALB |--->|  Airflow  |--+   +---------------+
  |         |    |    Web    |
  +---------+    +-----------+
```

## Initial Deploy

When doing an entirely new deploy the cluster will initially be configured to not have any tasks running. This is because there's some initialization that needs to happen before the cluster can be started. After the first `terraform apply` you'll need to do two things. You'll need the [workflow](https://github.com/MITLibraries/workflow) repo and [pipenv](https://github.com/pypa/pipenv):

```
$ git clone git@github.com:MITLibraries/workflow.git && cd workflow
$ pipenv install
```

The first thing you need to do is publish the initial version of our airflow container image. This assumes a staging version has already been published:

```
$ make promote
```

The next thing you need to do is initialize the cluster:

```
$ pipenv run workflow --cluster airflow-prod --scheduler airflow-prod-scheduler \
  --worker airflow-prod-worker --web airflow-prod-web initialize
```

This will start up a separate task in the airflow cluster. You'll need to watch the task in the AWS web console to make sure it has successfully run. The logs should show some messages about creating various tables in the database.

After the initialization task has run you can start the cluster:

```
$ pipenv run workflow --cluster airflow-prod --scheduler airflow-prod-scheduler \
  --worker airflow-prod-worker --web airflow-prod-web redeploy
```

This command will take several minutes to complete. It should show that the scheduler, worker and web have all been successfully started.

## Deploying After Changes

If you are deploying changes to scheduler service you need to stop the scheduler, deploy your changes and then start the scheduler. The reason this is necessary is to avoid any sort of race conditions with the scheduler restart. The steps will look like this:

```
$ pipenv run workflow --cluster airflow-prod --scheduler airflow-prod-scheduler \
  stop-scheduler
```

...deploy your Terraform changes

```
$ pipenv run workflow --cluster airflow-prod --scheduler airflow-prod-scheduler \
  start-scheduler
```
