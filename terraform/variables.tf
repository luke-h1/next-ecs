variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "project_name" {
  default = "ecs-next"
  type    = string
}

variable "env" {
  type        = string
  description = "The environment to deploy to"
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables to set on the container"
  default = {
    "NODE_ENV" = "production"
  }
}

variable "zone_id" {
  type        = string
  description = "The zone id of the route53 hosted zone"
}

variable "domain" {
  type        = string
  description = "The domain name to use for the service"
  default     = "ecs.lhowsam.com"
}

variable "private_key" {
  type        = string
  description = "The private key for the certificate"
}

variable "certificate_body" {
  type        = string
  description = "The certificate body for the certificate"
}

variable "certificate_chain" {
  type        = string
  description = "The certificate chain for the certificate"
}

variable "memory" {
  type        = number
  description = "The amount of memory to allocate to the container"
  default     = 128
}

variable "cpu" {
  type        = number
  description = "The amount of CPU units to allocate to the container"
  default     = 256
}

variable "task_count" {
  type        = number
  description = "The number of tasks to run on the cluster"
  default     = 1
}

variable "enable_autoscaling" {
  type        = bool
  description = "Whether or not to enable autoscaling for the service"
  default     = false
}

variable "min_capacity" {
  type        = number
  description = "The minimum number of tasks to run on the cluster"
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "The maximum number of tasks to run on the cluster"
  default     = 3
}
