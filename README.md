# Windows IIS AMI via Packer

This package can help create a Windows IIS AMI using HashiCorp Packer and deploy a single instance via Terraform. The steps are as follows:

1. Fill in the `win-2022-iis/iis.auto.pkrvars.hcl` values with networking values
2. Source shell with AWS Credentials (SSO or IAM user, etc)
3. Execute Packer (below)
4. Fill in `terraform/terraform.tfvars` with appropriate values

```shell
$ cd images/win-2022-iis
$ packer init .
$ packer build .
```

Packer will communicate from the execution environment (laptop, pipeline) directly to the VM created in AWS. For this reason the executing environment must have a route to the VM including security group entries for WinRM. Packer presents other communicators including [AWS Session Manager](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs#session-manager-connections) & [SSH](https://developer.hashicorp.com/packer/docs/communicators/ssh). Setup of other communicators for Windows is outside the scope of this document but you can find more information in the links provided.

# Deploy new AMI

Once your values are filled into the `terraform/terraform.tfvars` you can deploy the infrastructure:

Terraform is building a single VM using the AMI created in your account. To do that, Terraform needs to know the AMI id to reference when building the VM. We accomplish this using a [data source for the AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami), specifically, searching using the name specified in the Packer config as part of a regex + `most_recet = true`.

Additionally it will create a load balancer (AWS ALB) that will allow ingress communication based on the CIDR range defined in `var.lb_source_cidr_allow`. The instance has a security group that only allows traffic on port 80 from the LB itself (no other entities).

```shell
$ cd terraform
$ terraform init
$ terraform apply
```

Once complete, you should be able to hit the LB using the DNS record provided as a Terraform output to your stdout.