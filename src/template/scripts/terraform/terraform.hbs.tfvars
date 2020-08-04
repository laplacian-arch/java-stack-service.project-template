region = "us-central1"
zone = "b"
credentials_path = "../../.gcloud/CREDENTIALS.json"
cos_image="cos-stable-81-12871-181-0"
{{#each services as |service| ~}}
{{define "datasource" service.datasource ~}}
{{lower-snake service.name}}_image="gcr.io/{{project.group}}/{{hyphen service.name}}:latest"
{{lower-snake datasource.name}}_port=5432
{{lower-snake datasource.name}}_user="{{datasource.db_user}}"
{{lower-snake datasource.name}}_pass="{{datasource.db_password}}"
{{lower-snake datasource.name}}_machine_type="f1-micro"
{{/each}}