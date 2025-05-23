# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "home_region" {description = "Your tenancy home region"}
variable "region" {description = "Your tenancy region"}
variable "secondary_region" {description = "Your tenancy secondary region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "service_connectors_configuration" {
  description = "Service Connectors configuration settings, defining all aspects to manage service connectors and related resources in OCI. Please see the comments within each attribute for details."

  type = object({
    default_compartment_id = string, # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    service_connectors = map(object({
      display_name = string # the service connector name.
      compartment_id = optional(string) # the compartment where the service connector is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      description = optional(string) # the service connector description. Defaults to display_name if not defined.
      activate = optional(bool) # whether the service connector is active. Default is false.
      defined_tags = optional(map(string)) # the service connector defined_tags. Default to default_defined_tags if undefined.
      freeform_tags = optional(map(string)) # the service connector freeform_tags. Default to default_freeform_tags if undefined.

      source = object({
        kind = string # Supported sources: "logging" and "streaming".
        audit_logs = optional(list(object({ # the audit logs (only applicable if kind = "logging").
          cmp_id = string # the compartment where to get audit logs from. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID. Use "ALL" to include all audit logs in the tenancy.
        })))
        non_audit_logs = optional(list(object({ # all logs that are not audit logs. Includes bucket logs, flow logs, custom logs, etc (only applicable if kind = "logging").
          cmp_id = string # the compartment where to get non-audit logs from. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
          log_group_id = optional(string) # the log group. This attribute is overloaded: it can be either a log group OCID or a reference (a key) to the log group OCID.
          log_id = optional(string) # the log. This attribute is overloaded: it can be either a log OCID or a reference (a key) to the log OCID.
        })))
        stream_id = optional(string) # The source stream (only applicable if kind = "streaming"). This attribute is overloaded: it can be either a stream OCID or a reference (a key) to the stream OCID.
      })

      log_rule_filter = optional(string) # A condition for filtering log data (only applicable if source kind = "logging").
      
      target = object({ # the target
        kind = string, # supported targets: "objectstorage", "streaming", "functions", "logginganalytics", "notifications".
        bucket_name = optional(string), # the target bucket name (only applicable if kind is "objectstorage"). This attribute is overloaded: it can be either a bucket name or a reference (a key) to the bucket name.
        #bucket_key = optional(string), # the corresponding bucket key as defined in the buckets map object (only applicable if kind is "objectstorage"). 
        bucket_batch_rollover_size_in_mbs = optional(number), # the bucket batch rollover size in megabytes (only applicable if kind is "objectstorage"). 
        bucket_batch_rollover_time_in_ms = optional(number), # the bucket batch rollover time in milliseconds (only applicable if kind is "objectstorage"). 
        bucket_object_name_prefix = optional(string), # the prefix of objects eventually created in the bucket (only applicable if kind is "objectstorage").
        stream_id = optional(string) # the target stream (only applicable if kind is "streaming"). This attribute is overloaded: it can be either a stream OCID or a reference (a key) to the stream OCID.
        topic_id = optional(string) # the target topic (only applicable if kind is "notifications"). This attribute is overloaded: it can be either a topic OCID or a reference (a key) to the topic OCID.
        function_id = optional(string) # the target function (only applicable if kind is "functions"). This attribute is overloaded: it can be either a function OCID or a reference (a key) to the function OCID.
        log_group_id = optional(string) # the target log group (only applicable if kind is "logginganalytics"). This attribute is overloaded: it can be either a log group OCID or a reference (a key) to the log group OCID.
        compartment_id = optional(string), # the target resource compartment. Required if using a literal name for bucket_name or a literal OCID for stream_id, topic_id, function_id, or log_group_id. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
        #policy_name = optional(string) # the policy name allowing service connector to push data to target.
        #policy_description = optional(string) # the policy description.
      })

      policy = optional(object({ # If you omit this block in the declaration, the policy compartment_id, name and description are derived from the target.
        compartment_id = string, # the compartment where the policy is attached. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
        name = optional(string), # the policy name.
        description = optional(string) # the policy description.
      }))
    }))  

    buckets = optional(map(object({ # the buckets to manage.
      name = string, # the bucket name
      compartment_id = optional(string), # the compartment where the bucket is created. default_compartment_id is used if this is not defined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      cis_level = optional(string), # the cis_level. Default is "1". Drives bucket versioning and encryption. cis_level = "1": no versioning, encryption with Oracle managed key. cis_level = "2": versioning enabled, encryption with customer managed key.
      kms_key_id = optional(string), # the customer managed key. Required if cis_level = "2". This attribute is overloaded: it can be either a key OCID or a reference (a key) to the key OCID.
      defined_tags = optional(map(string)), # bucket defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # bucket freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    streams = optional(map(object({ # the streams to manage.
      name = string # the stream name
      compartment_id = optional(string) # the compartment where the stream is created. default_compartment_id is used if this is not defined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      num_partitions = optional(number) # the number of stream partitions. Default is 1.  
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    topics = optional(map(object({ # the topics to manage in this configuration.
      name = string # topic name
      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      description = optional(string) # topic description. Defaults to topic name if undefined.
      subscriptions = optional(list(object({
        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values = list(string) # list of endpoint values, specific to each protocol.
        defined_tags = optional(map(string)) # subscription defined_tags. The topic defined_tags is used if undefined.
        freeform_tags = optional(map(string)) # subscription freeform_tags. The topic freeform_tags is used if undefined.
      })))
      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.
    })))

  })    
}