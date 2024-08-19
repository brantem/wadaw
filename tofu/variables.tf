variable "name" {
  type = string
}

variable "managers" {
  default = 1
  type    = number
}

variable "manager_eip_id" {
  type      = string
  sensitive = true
}

variable "manager_type" {
  default = "t3.small"
  type    = string
}

variable "workers" {
  default = 1
  type    = number
}

variable "worker_eip_id" {
  type      = string
  sensitive = true
}

variable "worker_type" {
  default = "t3.small"
  type    = string
}
