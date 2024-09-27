// Auto-generated variable declarations from massdriver.yaml
variable "audit" {
  type = object({
    data_protection = number
  })
}
variable "azure_service_principal" {
  type = object({
    data = object({
      client_id       = string
      client_secret   = string
      subscription_id = string
      tenant_id       = string
    })
    specs = object({})
  })
}
variable "azure_virtual_network" {
  type = object({
    data = object({
      infrastructure = object({
        cidr              = string
        default_subnet_id = string
        id                = string
      })
    })
    specs = optional(object({
      azure = optional(object({
        region = string
      }))
    }))
  })
}
variable "database" {
  type = object({
    max_capacity = number
    min_capacity = number
  })
}
variable "elasticpool" {
  type = object({
    model          = string
    capacity       = optional(number)
    max_size       = optional(number)
    tier           = optional(string)
    zone_redundant = optional(bool)
  })
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "monitoring" {
  type = object({
    mode = optional(string)
    alarms = optional(object({
      cpu_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
      dtu_percent_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
      storage_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
    }))
  })
}
variable "network" {
  type = object({
    auto = bool
    cidr = optional(string)
  })
}
variable "server" {
  type = object({
    admin_login = string
    version     = string
  })
}
