## Application Load balancers
General:
* We currently create 2 ALB's per VPC
  * One with public access (no restrictions)
  * One with restricted access to MIT-Only (18.0.0.0/9)
* Security groups for each ALB
* Each ALB is configured to use the \*.mitlib.net certificate
* Default HTTP and HTTPS (port 80 and 443) listeners and target groups

_Additional information about Application Load Balancers is available from the [AWS User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)_
