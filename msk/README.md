# msk

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.23.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.msk_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_kms_alias.msk_kms_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.msk_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.msk_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_msk_cluster.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_msk_configuration.msk_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_configuration) | resource |
| [aws_security_group.msk_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.broker_sasl_iam_inbound_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.broker_sasl_iam_inbound_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.msk_sasl_iam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.zookeeper](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.zookeeper_inbound_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_broker_inbound_cidr_blocks"></a> [broker\_inbound\_cidr\_blocks](#input\_broker\_inbound\_cidr\_blocks) | Broker Inbound cidr blocks | `list(string)` | <pre>[<br/>  "10.23.0.0/16"<br/>]</pre> | no |
| <a name="input_broker_inbound_security_group_ids"></a> [broker\_inbound\_security\_group\_ids](#input\_broker\_inbound\_security\_group\_ids) | Broker Inbound security group ids | `list(string)` | `[]` | no |
| <a name="input_client_sasl_iam_enabled"></a> [client\_sasl\_iam\_enabled](#input\_client\_sasl\_iam\_enabled) | Enables client authentication via IAM policies | `bool` | `true` | no |
| <a name="input_client_subnets"></a> [client\_subnets](#input\_client\_subnets) | A list of subnets to connect to in client VPC | `list(string)` | <pre>[<br/>  "subnet-xxxxx",<br/>  "subnet-yyyyy"<br/>]</pre> | no |
| <a name="input_cloudwatch_logs_group_enabled"></a> [cloudwatch\_logs\_group\_enabled](#input\_cloudwatch\_logs\_group\_enabled) | Indicates whether you want to enable or disable the CloudWatch Logs Group. | `bool` | `true` | no |
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting log data. If not provided, CloudWatch Logs uses the default AWS managed key for CloudWatch Logs. | `string` | `null` | no |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | Specifies the number of days you want to retain log events in the CloudWatch log group. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0 (never expire). | `number` | `3` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the MSK cluster. | `string` | `"msk"` | no |
| <a name="input_encryption_in_transit_client_broker"></a> [encryption\_in\_transit\_client\_broker](#input\_encryption\_in\_transit\_client\_broker) | Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS\_PLAINTEXT, and PLAINTEXT. Default value is TLS (recommended for security). | `string` | `"TLS"` | no |
| <a name="input_encryption_in_transit_in_cluster"></a> [encryption\_in\_transit\_in\_cluster](#input\_encryption\_in\_transit\_in\_cluster) | Whether data communication among broker nodes is encrypted. Default value: true. | `bool` | `true` | no |
| <a name="input_enhanced_monitoring"></a> [enhanced\_monitoring](#input\_enhanced\_monitoring) | Specify the desired enhanced MSK CloudWatch monitoring level to one of three monitoring levels: DEFAULT, PER\_BROKER, PER\_TOPIC\_PER\_BROKER or PER\_TOPIC\_PER\_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html). | `string` | `"DEFAULT"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specify the instance type to use for the kafka brokers. | `string` | `"kafka.m7g.large"` | no |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | Specify the desired Kafka software version. | `string` | `"3.8.0"` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource. Must be between 7 and 30 days. | `number` | `30` | no |
| <a name="input_number_of_broker_nodes"></a> [number\_of\_broker\_nodes](#input\_number\_of\_broker\_nodes) | The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets. | `number` | `4` | no |
| <a name="input_prometheus_jmx_exporter_enabled"></a> [prometheus\_jmx\_exporter\_enabled](#input\_prometheus\_jmx\_exporter\_enabled) | Indicates whether you want to enable or disable the JMX Exporter. | `bool` | `true` | no |
| <a name="input_prometheus_node_exporter_enabled"></a> [prometheus\_node\_exporter\_enabled](#input\_prometheus\_node\_exporter\_enabled) | Indicates whether you want to enable or disable the Node Exporter. | `bool` | `true` | no |
| <a name="input_server_properties"></a> [server\_properties](#input\_server\_properties) | A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html). | `map(string)` | <pre>{<br/>  "log.cleanup.policy": "delete",<br/>  "log.retention.hours": 72<br/>}</pre> | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size in GiB of the EBS volume for the data drive on each broker node. | `number` | `64` | no |
| <a name="input_zookeeper_inbound_cidr_blocks"></a> [zookeeper\_inbound\_cidr\_blocks](#input\_zookeeper\_inbound\_cidr\_blocks) | Zookeeper Inbound cidr blocks | `list(string)` | <pre>[<br/>  "10.23.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_msk_cloudwatch_log_group_arn"></a> [msk\_cloudwatch\_log\_group\_arn](#output\_msk\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch Log Group for MSK |
| <a name="output_msk_cloudwatch_log_group_name"></a> [msk\_cloudwatch\_log\_group\_name](#output\_msk\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for MSK |
| <a name="output_msk_cluster_arn"></a> [msk\_cluster\_arn](#output\_msk\_cluster\_arn) | Amazon Resource Name (ARN) of the MSK cluster |
| <a name="output_msk_cluster_bootstrap_brokers"></a> [msk\_cluster\_bootstrap\_brokers](#output\_msk\_cluster\_bootstrap\_brokers) | Plaintext connection host:port pairs |
| <a name="output_msk_cluster_bootstrap_brokers_sasl_iam"></a> [msk\_cluster\_bootstrap\_brokers\_sasl\_iam](#output\_msk\_cluster\_bootstrap\_brokers\_sasl\_iam) | SASL/IAM authentication connection host:port pairs |
| <a name="output_msk_cluster_bootstrap_brokers_sasl_scram"></a> [msk\_cluster\_bootstrap\_brokers\_sasl\_scram](#output\_msk\_cluster\_bootstrap\_brokers\_sasl\_scram) | SASL/SCRAM authentication connection host:port pairs |
| <a name="output_msk_cluster_bootstrap_brokers_tls"></a> [msk\_cluster\_bootstrap\_brokers\_tls](#output\_msk\_cluster\_bootstrap\_brokers\_tls) | TLS encrypted connection host:port pairs |
| <a name="output_msk_cluster_current_version"></a> [msk\_cluster\_current\_version](#output\_msk\_cluster\_current\_version) | Current version of the MSK cluster |
| <a name="output_msk_cluster_id"></a> [msk\_cluster\_id](#output\_msk\_cluster\_id) | ID of the MSK cluster |
| <a name="output_msk_cluster_name"></a> [msk\_cluster\_name](#output\_msk\_cluster\_name) | Name of the MSK cluster |
| <a name="output_msk_cluster_zookeeper_connect_string"></a> [msk\_cluster\_zookeeper\_connect\_string](#output\_msk\_cluster\_zookeeper\_connect\_string) | Zookeeper connection string |
| <a name="output_msk_configuration_arn"></a> [msk\_configuration\_arn](#output\_msk\_configuration\_arn) | ARN of the MSK configuration |
| <a name="output_msk_configuration_latest_revision"></a> [msk\_configuration\_latest\_revision](#output\_msk\_configuration\_latest\_revision) | Latest revision of the MSK configuration |
| <a name="output_msk_kms_key_alias"></a> [msk\_kms\_key\_alias](#output\_msk\_kms\_key\_alias) | Alias of the KMS key used for MSK encryption |
| <a name="output_msk_kms_key_arn"></a> [msk\_kms\_key\_arn](#output\_msk\_kms\_key\_arn) | ARN of the KMS key used for MSK encryption |
| <a name="output_msk_kms_key_id"></a> [msk\_kms\_key\_id](#output\_msk\_kms\_key\_id) | ID of the KMS key used for MSK encryption |
| <a name="output_msk_security_group_id"></a> [msk\_security\_group\_id](#output\_msk\_security\_group\_id) | ID of the MSK security group |
<!-- END_TF_DOCS -->
