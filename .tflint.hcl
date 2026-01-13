 ################################################################################
 # TFLint Configuration
 # Documentation: https://github.com/terraform-linters/tflint
 ################################################################################
 
 config {
   # Check both local and remote module calls
   call_module_type = "all"
   force            = false
 }
 
 ################################################################################
 # Terraform Plugin
 ################################################################################
 
 plugin "terraform" {
   enabled = true
   preset  = "recommended"
 }
 
 ################################################################################
 # AWS Plugin
 ################################################################################
 
 ################################################################################
 # Note: AWS plugin (v0.44.0) with deep_check enabled already includes many security rules.
 # - Encryption at rest checks (S3, EBS, RDS, etc.)
 # - Public access checks (S3 buckets, security groups, etc.)
 # - IMDSv2 enforcement
 # - And many more AWS security best practices
 # 
 # Most AWS security rules are enabled by default when the AWS plugin is enabled.
 # Check https://github.com/terraform-linters/tflint-ruleset-aws for full rule list.
 ################################################################################
 
 plugin "aws" {
   enabled    = true
   version    = "0.44.0"
   source     = "github.com/terraform-linters/tflint-ruleset-aws"
   deep_check = true
 }
 
 ################################################################################
 # Naming Convention Rules
 ################################################################################
 
 rule "terraform_naming_convention" {
   enabled = true
   format  = "snake_case"
 
   # Allow exceptions for resource names that may need different conventions
   check_resource = true
   check_variable = true
   check_output   = true
   check_module   = true
   check_locals   = true
 }
 
 ################################################################################
 # Documentation Rules
 ################################################################################
 
 rule "terraform_documented_variables" {
   enabled = true
   format  = "restricted" # Require description for all variables
 }
 
 rule "terraform_documented_outputs" {
   enabled = true
   format  = "restricted" # Require description for all outputs
 }
 
 ################################################################################
 # Type Safety Rules
 ################################################################################
 
 rule "terraform_typed_variables" {
   enabled = true
 }
 
 ################################################################################
 # Code Quality Rules
 ################################################################################
 
 rule "terraform_unused_declarations" {
   enabled = true
 }
 
 rule "terraform_required_version" {
   enabled = true
 }
 
 rule "terraform_required_providers" {
   enabled = true
 }
 
 ################################################################################
 # Deprecation Rules
 ################################################################################
 
 rule "terraform_deprecated_index" {
   enabled = true
 }
 
 ################################################################################
 # Module Management Rules
 ################################################################################
 
 rule "terraform_module_pinned_source" {
   enabled = true
   style   = "flexible" # Allow tags/branches but require pinning
 }
 
 ################################################################################
 # AWS-Specific Rules (Custom Configurations)
 ################################################################################
 
 rule "aws_resource_missing_tags" {
   enabled = true # Enforce mandatory tags for resource management and cost tracking
   # Optional: Specify required tags (uncomment and customize as needed)
   # tags = ["Environment", "Project", "Owner", "CostCenter"]
   # exclude = ["aws_autoscaling_group"] # Exclude specific resource types if needed
 }
 
 rule "aws_instance_invalid_type" {
   enabled = true # Validate EC2 instance types to prevent invalid configurations
 }
