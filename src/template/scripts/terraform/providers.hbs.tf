provider "google" {
    credentials = file(var.credentials_path)
    project = "{{hyphen project.group}}"
    region = var.region
}
