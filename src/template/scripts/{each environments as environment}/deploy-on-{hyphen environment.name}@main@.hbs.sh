DEPLOYMENT_BASE_DIR=$PROJECT_BASE_DIR/dest/{{hyphen environment.name}}/
{{define "springboot2_services"
  (filter environment.components '(eq @it.type "springboot2_api_service")')
~}}
main () {
  {{#if environment.uses_locally_built_container_images ~}}
  build_apps
  {{/if}}
  {{#if (eq environment.tier 'local') ~}}
  run_local_container
  {{/if}}
  {{#if environment.uses_gcp ~}}
  register_container_images
  deploy_with_terraform
  migrate_test_data
  {{/if}}
}

{{#if environment.uses_locally_built_container_images ~}}
build_apps() {
  {{#each springboot2_services as |springboot2_service| ~}}
  {{define "service_name" springboot2_service.function_model.name ~}}
  {{#each springboot2_service.datasource_mappings as |datasource_mapping| ~}}
  {{define "datasource" datasource_mapping.datasource ~}}
  (cd $DEPLOYMENT_BASE_DIR/{{hyphen service_name}}-{{hyphen datasource.name}}-datasource-migrate
    ./gradlew build
  )
  {{/each}}
  (cd $DEPLOYMENT_BASE_DIR/{{hyphen service_name}}
    ./gradlew build
  )
  {{/each}}
}
{{/if}}

{{#if (eq environment.tier 'local') ~}}
run_local_container() {
  (cd $DEPLOYMENT_BASE_DIR
    docker-compose \
      up \
      --force-recreate \
      --build
  )
}
{{/if}}

{{#if environment.uses_gcp ~}}
register_container_images() {
  (cd $DEPLOYMENT_BASE_DIR
    docker-compose build
    docker-compose push
  )
}

deploy_with_terraform() {
  (cd $DEPLOYMENT_BASE_DIR/terraform
    terraform init
    terraform apply -auto-approve
  )
}

migrate_test_data() {
  local datastore_ip=
  {{#each springboot2_services as |springboot2_service| ~}}
  {{define "service_name" springboot2_service.function_model.name ~}}
  {{#each springboot2_service.datasource_mappings as |datasource_mapping| ~}}
  {{define "datasource" datasource_mapping.datasource ~}}
  {{define "datastore" datasource_mapping.component ~}}
  datastore_ip=$(cd $DEPLOYMENT_BASE_DIR/terraform && terraform output {{lower-snake datastore.name}}_ip)
  (cd $DEPLOYMENT_BASE_DIR/{{hyphen service_name}}-{{hyphen datasource.name}}-datasource-migrate
    java  \
      -Ddatasource.url="{{replace datastore.jdbc_connection_string datastore.instance_name '\$datastore_ip'}}" \
      -Ddatasource.username="test" \
      -Ddatasource.password="secret" \
      -jar ./build/libs/db-migrate-*.jar
  )
  {{/each}}
  {{/each}}
}
{{/if}}