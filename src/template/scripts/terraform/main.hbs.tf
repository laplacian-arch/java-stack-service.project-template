data "google_compute_network" "default" {
    name = "default"
}

{{#each services as |service| ~}}
{{define "datasource" service.datasource ~}}
resource "google_compute_firewall" "{{hyphen datasource.name}}-port" {
    name = "{{hyphen datasource.name}}-port"
    network = data.google_compute_network.default.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports = [var.{{lower-snake datasource.name}}_port]
    }
}

resource "google_compute_instance" "default" {
    name = "default"
    machine_type = var.{{lower-snake datasource.name}}_machine_type
    zone = "${var.region}-${var.zone}"
    tags = [ "name", "default" ]
    boot_disk {
        auto_delete = true
        initialize_params {
            image = "projects/cos-cloud/global/images/${var.cos_image}"
            type="pd-standard"
        }
    }
    labels = {
        container-vm = var.cos_image
    }
    network_interface {
        network = "default"
        access_config {
        }
    }
    metadata = {
        gce-container-declaration = <<EOF
spec:
  containers:
  - name: {{hyphen datasource.name}}
    image: postgres
    stdin: false
    tty: false
    restartPolicy: Always
    env:
    - name: POSTGRES_USER
      value: ${var.{{lower-snake datasource.name}}_user}
    - name: POSTGRES_PASSWORD
      value: ${var.{{lower-snake datasource.name}}_pass}
    - name: POSTGRES_DB
      value: {{lower-snake datasource.name}}
EOF
    }
}

locals {
    {{lower-snake datasource.name}}_ip = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "{{lower-snake datasource.name}}_ip" {
    value = local.{{lower-snake datasource.name}}_ip
}

resource "google_cloud_run_service" "{{hyphen service.name}}" {
    name = "{{hyphen service.name}}"
    location = var.region
    template {
        spec {
            containers {
                image = var.{{lower-snake service.name}}_image
                env {
                    name = "DATASOURCE_URL"
                    value = "r2dbc:pool:postgresql://${local.{{lower-snake datasource.name}}_ip}:${var.{{lower-snake datasource.name}}_port}/{{lower-snake datasource.name}}"
                }
                env {
                    name = "DATASOURCE_USER"
                    value = var.{{lower-snake datasource.name}}_user
                }
                env {
                    name = "DATASOURCE_PASS"
                    value = var.{{lower-snake datasource.name}}_pass
                }
            }
        }
    }
    traffic {
        percent = 100
        latest_revision = true
    }
}

data "google_iam_policy" "public-access" {
    binding {
        role = "roles/run.invoker"
        members = [
            "allUsers"
        ]
    }
}

resource "google_cloud_run_service_iam_policy" "public-access" {
    location = google_cloud_run_service.{{hyphen service.name}}.location
    project = google_cloud_run_service.{{hyphen service.name}}.project
    service = google_cloud_run_service.{{hyphen service.name}}.name
    policy_data = data.google_iam_policy.public-access.policy_data
}

output "url" {
    value = "${google_cloud_run_service.{{hyphen service.name}}.status[0].url}"
}
{{/each}}
