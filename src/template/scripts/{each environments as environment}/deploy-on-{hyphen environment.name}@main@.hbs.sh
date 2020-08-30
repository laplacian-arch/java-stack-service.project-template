DEPLOYMENT_BASE_DIR=$PROJECT_BASE_DIR/dest/{{hyphen environment.name}}/
{{define "springboot2_services"
  (filter environment.components '(eq @it.type "springboot2_api_service")')
~}}
main () {
  {{#if environment.uses_locally_built_container_images ~}}
  build_container_images
  {{/if}}
  run
}

{{#if environment.uses_locally_built_container_images ~}}
build_container_images() {
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

run() {
  (cd $DEPLOYMENT_BASE_DIR
    docker-compose \
      up \
      --force-recreate \
      --build
  )
}