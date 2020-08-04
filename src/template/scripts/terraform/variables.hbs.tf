variable "region" {
    type = string
}

variable "zone" {
    type = string
}

variable "credentials_path" {
    type = string
}

variable "cos_image" {
    type = string
}

{{#each services as |service| ~}}
{{define "datasource" service.datasource ~}}
variable "{{lower-snake service.name}}_image" {
    type = string
}

variable "{{lower-snake datasource.name}}_port" {
    type = number
}

variable "{{lower-snake datasource.name}}_machine_type" {
    type = string
}

variable "{{lower-snake datasource.name}}_user" {
    type = string
}

variable "{{lower-snake datasource.name}}_pass" {
    type = string
}
{{/each}}