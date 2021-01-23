
resource "google_compute_firewall" "{{hyphen component.name}}-port" {
    name = "{{hyphen component.name}}-port"
    network = data.google_compute_network.default.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports = [var.{{lower-snake component.name}}_port]
    }
}

resource "google_compute_instance" "default" {
    name = "default"
    machine_type = var.{{lower-snake component.name}}_machine_type
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
  - name: {{hyphen component.name}}
    image: {{component.container_image}}
    stdin: false
    tty: false
    restartPolicy: Always
    env:
    - name: POSTGRES_USER
      value: ${var.{{lower-snake component.name}}_user}
    - name: POSTGRES_PASSWORD
      value: ${var.{{lower-snake component.name}}_pass}
    - name: POSTGRES_DB
      value: {{lower-snake component.database_name}}
EOF
    }
}

locals {
    {{lower-snake component.name}}_ip = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "{{lower-snake component.name}}_ip" {
    value = local.{{lower-snake component.name}}_ip
}
