variable "cluster_name" {
  description = "Name of the MSK cluster."
  type        = string
  default     = "msk"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.cluster_name)) && length(var.cluster_name) <= 64
    error_message = "Cluster name must start with a letter, contain only alphanumeric characters and hyphens, and be 64 characters or less."
  }
}

variable "kafka_version" {
  description = "Specify the desired Kafka software version."
  type        = string
  default     = "3.8.0"
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  type        = number
  default     = 4

  validation {
    condition     = var.number_of_broker_nodes >= 2 && var.number_of_broker_nodes % length(var.client_subnets) == 0
    error_message = "Number of broker nodes must be at least 2 and must be a multiple of the number of client subnets."
  }
}

variable "client_subnets" {
  description = "A list of subnets to connect to in client VPC"
  type        = list(string)
  default     = ["subnet-xxxxx", "subnet-yyyyy"]
}

variable "instance_type" {
  description = "Specify the instance type to use for the kafka brokers."
  type        = string
  default     = "kafka.m7g.large"
}

variable "volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node."
  type        = number
  default     = 64
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level to one of three monitoring levels: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "PER_BROKER", "PER_TOPIC_PER_BROKER", "PER_TOPIC_PER_PARTITION"], var.enhanced_monitoring)
    error_message = "Enhanced monitoring must be one of: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION."
  }
}

variable "server_properties" {
  description = "A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)."
  type        = map(string)
  default = {
    "log.cleanup.policy"  = "delete"
    "log.retention.hours" = 72
  }
}

variable "broker_inbound_cidr_blocks" {
  description = "Broker Inbound cidr blocks"
  type        = list(string)
  default     = ["10.23.0.0/16"]
}

variable "broker_inbound_security_group_ids" {
  description = "Broker Inbound security group ids"
  type        = list(string)
  default     = []
}

variable "zookeeper_inbound_cidr_blocks" {
  description = "Zookeeper Inbound cidr blocks"
  type        = list(string)
  default     = ["10.23.0.0/16"]
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT. Default value is TLS (recommended for security)."
  type        = string
  default     = "TLS"

  validation {
    condition     = contains(["TLS", "TLS_PLAINTEXT", "PLAINTEXT"], var.encryption_in_transit_client_broker)
    error_message = "Encryption in transit client-broker must be one of: TLS, TLS_PLAINTEXT, PLAINTEXT."
  }
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted. Default value: true."
  type        = bool
  default     = true
}

variable "client_sasl_iam_enabled" {
  description = "Enables client authentication via IAM policies"
  type        = bool
  default     = true
}

variable "prometheus_jmx_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the JMX Exporter."
  type        = bool
  default     = true
}

variable "prometheus_node_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the Node Exporter."
  type        = bool
  default     = true
}

variable "cloudwatch_logs_group_enabled" {
  description = "Indicates whether you want to enable or disable the CloudWatch Logs Group."
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the CloudWatch log group. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0 (never expire)."
  type        = number
  default     = 3

  validation {
    condition = contains([
      0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch logs retention must be one of the valid values: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "cloudwatch_logs_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data. If not provided, CloudWatch Logs uses the default AWS managed key for CloudWatch Logs."
  type        = string
  default     = null
}

# Note: EBS volume type and provisioned throughput are not configurable for MSK
# MSK automatically manages EBS volumes and selects the appropriate volume type
# based on the instance type. Typically, MSK uses gp3 volumes for better performance.

variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource. Must be between 7 and 30 days."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}
