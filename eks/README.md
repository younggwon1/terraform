# eks

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.28.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 21.10.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.eks-worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.eks-worker-autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks-master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks-worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks-worker-autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks-master-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-master-service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_cluster_to_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_to_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.eks_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [tls_certificate.eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cluster_tags"></a> [additional\_cluster\_tags](#input\_additional\_cluster\_tags) | Additional tags to apply to the EKS cluster and its resources | `map(string)` | `{}` | no |
| <a name="input_availability_zone_names"></a> [availability\_zone\_names](#input\_availability\_zone\_names) | n/a | `list(string)` | <pre>[<br/>  "ap-northeast-2a",<br/>  "ap-northeast-2c"<br/>]</pre> | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | EKS cluster addons and their versions | <pre>map(object({<br/>    addon_version = string<br/>  }))</pre> | <pre>{<br/>  "coredns": {<br/>    "addon_version": "v1.12.4-eksbuild.1",<br/>    "resolve_conflicts_on_create": "OVERWRITE"<br/>  },<br/>  "kube-proxy": {<br/>    "addon_version": "v1.34.0-eksbuild.4",<br/>    "resolve_conflicts_on_create": "OVERWRITE"<br/>  },<br/>  "vpc-cni": {<br/>    "addon_version": "v1.20.3-eksbuild.1",<br/>    "resolve_conflicts_on_create": "OVERWRITE"<br/>  }<br/>}</pre> | no |
| <a name="input_cluster_admin_role_arn"></a> [cluster\_admin\_role\_arn](#input\_cluster\_admin\_role\_arn) | IAM Role ARN for EKS cluster admin access entry | `string` | `"arn:aws:iam::<account_id>:role/aws-reserved/sso.amazonaws.com/ap-northeast-2/AWSReservedSSO_<role_name>_<role_id>"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"eks"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | `"1.34"` | no |
| <a name="input_cluster_viewer_role_arn"></a> [cluster\_viewer\_role\_arn](#input\_cluster\_viewer\_role\_arn) | IAM Role ARN for EKS cluster view-only access entry | `string` | `"arn:aws:iam::<account_id>:role/aws-reserved/sso.amazonaws.com/ap-northeast-2/AWSReservedSSO_<role_name>_<role_id>"` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Whether the EKS cluster endpoint is privately accessible within the VPC | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Whether the EKS cluster endpoint is publicly accessible | `bool` | `false` | no |
| <a name="input_mixed_instances_on_demand_base_capacity"></a> [mixed\_instances\_on\_demand\_base\_capacity](#input\_mixed\_instances\_on\_demand\_base\_capacity) | Minimum number of on-demand instances to maintain for stability | `number` | `1` | no |
| <a name="input_mixed_instances_on_demand_percentage"></a> [mixed\_instances\_on\_demand\_percentage](#input\_mixed\_instances\_on\_demand\_percentage) | Percentage of on-demand instances above base capacity (0-100) | `number` | `50` | no |
| <a name="input_mixed_instances_spot_max_price"></a> [mixed\_instances\_spot\_max\_price](#input\_mixed\_instances\_spot\_max\_price) | Maximum price per hour for Spot instances (empty string = on-demand price) | `string` | `""` | no |
| <a name="input_mixed_instances_spot_pools"></a> [mixed\_instances\_spot\_pools](#input\_mixed\_instances\_spot\_pools) | Number of Spot instance pools to use (1-20). More pools increase availability but may increase cost. | `number` | `4` | no |
| <a name="input_mixed_instances_weights"></a> [mixed\_instances\_weights](#input\_mixed\_instances\_weights) | Weighted capacity for each instance type in mixed\_instances\_policy. Key is instance type, value is weight. | `map(number)` | `{}` | no |
| <a name="input_node_ami_id"></a> [node\_ami\_id](#input\_node\_ami\_id) | Custom AMI ID for the self-managed worker node group (if null, EKS-optimized default is used) | `string` | `null` | no |
| <a name="input_node_desired_size"></a> [node\_desired\_size](#input\_node\_desired\_size) | Desired number of worker nodes in the self-managed node group | `number` | `2` | no |
| <a name="input_node_disk_size"></a> [node\_disk\_size](#input\_node\_disk\_size) | Disk size in GiB for worker nodes in the self-managed node group | `number` | `100` | no |
| <a name="input_node_instance_types"></a> [node\_instance\_types](#input\_node\_instance\_types) | Instance types for the self-managed worker node group (used in mixed\_instances\_policy) | `list(string)` | <pre>[<br/>  "m5.xlarge",<br/>  "m5a.xlarge",<br/>  "m5d.xlarge"<br/>]</pre> | no |
| <a name="input_node_launch_template_id"></a> [node\_launch\_template\_id](#input\_node\_launch\_template\_id) | ID of the custom launch template to use when use\_custom\_launch\_template is true | `string` | `null` | no |
| <a name="input_node_max_size"></a> [node\_max\_size](#input\_node\_max\_size) | Maximum number of worker nodes in the self-managed node group | `number` | `10` | no |
| <a name="input_node_min_size"></a> [node\_min\_size](#input\_node\_min\_size) | Minimum number of worker nodes in the self-managed node group | `number` | `2` | no |
| <a name="input_use_custom_launch_template"></a> [use\_custom\_launch\_template](#input\_use\_custom\_launch\_template) | Whether to use a custom launch template for the self-managed node group | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
