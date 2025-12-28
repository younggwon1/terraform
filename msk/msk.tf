locals {
  server_properties = join("\n", [for k, v in var.server_properties : format("%s: %s", k, v)])
}

resource "aws_security_group" "msk_security_group" {
  name_prefix = "${var.cluster_name}-"
  description = "Security group for MSK cluster ${var.cluster_name}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name        = "${var.cluster_name}-sg"
    Description = "MSK cluster security group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "msk_sasl_iam" {
  description       = "MSK SASL/SCRAM with IAM"
  from_port         = 9098
  to_port           = 9098
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "zookeeper" {
  description       = "Zookeeper"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "broker_sasl_iam_inbound_rule" {
  description       = "Broker(sasl-iam) Inbound IP Address"
  from_port         = 9098
  to_port           = 9098
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  type              = "ingress"
  cidr_blocks       = var.broker_inbound_cidr_blocks
}

resource "aws_security_group_rule" "broker_sasl_iam_inbound_security_group_rule" {
  description              = "Broker(sasl-iam) Inbound Security Group - ${count.index}"
  count                    = var.client_sasl_iam_enabled ? length(var.broker_inbound_security_group_ids) : 0
  from_port                = 9098
  to_port                  = 9098
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk_security_group.id
  source_security_group_id = var.broker_inbound_security_group_ids[count.index]
  type                     = "ingress"
}

resource "aws_security_group_rule" "zookeeper_inbound_rule" {
  description       = "Zookeeper Inbound IP Address"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  type              = "ingress"
  cidr_blocks       = var.zookeeper_inbound_cidr_blocks
}

resource "aws_security_group_rule" "vpc_egress" {
  description       = "Allow all outbound traffic from MSK cluster"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.msk_security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_msk_configuration" "msk_configuration" {
  kafka_versions    = [var.kafka_version]
  name              = "${var.cluster_name}-configuration"
  description       = "MSK configuration for ${var.cluster_name}"
  server_properties = local.server_properties

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  configuration_info {
    arn      = aws_msk_configuration.msk_configuration.arn
    revision = aws_msk_configuration.msk_configuration.latest_revision
  }

  broker_node_group_info {
    instance_type  = var.instance_type
    client_subnets = var.client_subnets
    storage_info {
      ebs_storage_info {
        # Note: MSK manages EBS volume type automatically (typically gp3)
        # volume_type and provisioned_throughput are not configurable via Terraform
        # MSK automatically selects the appropriate volume type based on instance type
        volume_size = var.volume_size
      }
    }
    security_groups = [aws_security_group.msk_security_group.id]
  }

  client_authentication {
    sasl {
      iam = var.client_sasl_iam_enabled
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_kms_key.arn
    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus_jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.prometheus_node_exporter_enabled
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_group_enabled
        log_group = aws_cloudwatch_log_group.msk_cloudwatch_log_group.name
      }
    }
  }

  tags = {
    Name        = var.cluster_name
    Description = "MSK Kafka cluster"
  }

  # IMPORTANT: Terraform lifecycle blocks do not support variables or any expressions.
  # They only accept literal boolean values (true or false).
  # 
  # To control prevent_destroy behavior:
  # - For production: Set prevent_destroy = true (default, protects against accidental deletion)
  # - For non-production: Set prevent_destroy = false or remove this lifecycle block
  # 
  # To delete a protected resource, you must:
  # 1. Manually edit this file and set prevent_destroy = false
  # 2. Run terraform apply to update the lifecycle
  # 3. Run terraform destroy to delete the resource
  #
  # Current setting: prevent_destroy = true (production-safe default)
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      # Ignore changes to configuration revision as it's managed separately
      configuration_info[0].revision,
    ]
  }
}
