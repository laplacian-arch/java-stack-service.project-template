provider "google" {
    credentials = file(var.credentials_path)
    project = "laplacian-arch"
    region = var.region
}