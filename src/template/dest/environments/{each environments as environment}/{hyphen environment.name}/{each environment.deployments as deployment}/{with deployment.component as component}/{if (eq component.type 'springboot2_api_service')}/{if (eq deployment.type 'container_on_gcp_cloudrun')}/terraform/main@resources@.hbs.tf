resource "google_cloud_run_service" "{{hyphen component.name}}" {
    name = "{{hyphen component.name}}"
    location = var.region
    template {
        spec {
            containers {
                image = var.{{lower-snake component.name}}_image
                {{#each component.datasource_mappings as |mapping| ~}}
                {{define 'datastore' mapping.component ~}}
                {{define "DS_PREFIX" (concat
                  'DATASOURCE'
                  (if mapping.default '' (concat '_' (upper-snake mapping.name)))
                ) ~}}
                env {
                    name = "{{DS_PREFIX}}_URL"
                    value = "r2dbc:pool:postgresql://${local.{{lower-snake datastore.name}}_ip}:${var.{{lower-snake datastore.name}}_port}/{{datastore.database_name}}"
                }
                env {
                    name = "{{DS_PREFIX}}_USER"
                    value = var.{{lower-snake datastore.name}}_user
                }
                env {
                    name = "{{DS_PREFIX}}_PASS"
                    value = var.{{lower-snake datastore.name}}_pass
                }
                {{/each}}
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
    location = google_cloud_run_service.{{hyphen component.name}}.location
    project = google_cloud_run_service.{{hyphen component.name}}.project
    service = google_cloud_run_service.{{hyphen component.name}}.name
    policy_data = data.google_iam_policy.public-access.policy_data
}

output "url" {
    value = "${google_cloud_run_service.{{hyphen component.name}}.status[0].url}"
}
