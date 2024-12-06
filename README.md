# Windows IIS AMI via Packer

This package can help create a Windows IIS AMI using HashiCorp Packer. The steps are as follows:

1. Fill in the `images/win-2022-iis/iis.auto.pkrvars.hcl` values with networking values
2. Source shell with AWS Credentials (SSO or IAM user, etc)
3. Execute Packer (below)

```shell
$ cd images/win-2022-iis
$ packer init .
$ packer build .
```

Packer will communicate from the execution environment (laptop, pipeline) directly to the VM created in AWS. For this reason the executing environment must have a route to the VM including security group entries for WinRM. Packer presents other communicators including [AWS Session Manager](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs#session-manager-connections) & [SSH](https://developer.hashicorp.com/packer/docs/communicators/ssh). Setup of other communicators for Windows is outside the scope of this document but you can find more information in the links provided.