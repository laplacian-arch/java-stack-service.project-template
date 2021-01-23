{{define 'prefix' (lower-snake component.name) ~}}
variable "{{prefix}}_port" {
    type = number
}

variable "{{prefix}}_machine_type" {
    type = string
}

variable "{{prefix}}_user" {
    type = string
}

variable "{{prefix}}_pass" {
    type = string
}
