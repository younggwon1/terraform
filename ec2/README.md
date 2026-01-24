# ec2

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_c_type_instance"></a> [ec2\_c\_type\_instance](#module\_ec2\_c\_type\_instance) | ./modules/ec2-instance | n/a |
| <a name="module_ec2_m_type_instance"></a> [ec2\_m\_type\_instance](#module\_ec2\_m\_type\_instance) | ./modules/ec2-instance | n/a |
| <a name="module_ec2_t_type_instance"></a> [ec2\_t\_type\_instance](#module\_ec2\_t\_type\_instance) | ./modules/ec2-instance | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.acm](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
