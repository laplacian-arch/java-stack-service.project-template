{{define 'deployment_components' (unique (map environment.deployments '@it.component')) ~}}
DEPLOYMENT_BASE_DIR=$PROJECT_BASE_DIR/dest/environments/{{hyphen environment.name}}
COMPONENT_BASE_DIR=$PROJECT_BASE_DIR/dest/components

main () {
  {{#each deployment_components as |component| ~}}
  {{#if component.custom_built ~}}
  build_{{lower-snake component.name}}
  {{/if}}
  {{/each}}
  migrate_data
  deploy_containers
}

migrate_data() {
  echo "Migrating application data and schema..."
}

deploy_containers() {
  echo "Deploying application modules..."
  (cd $DEPLOYMENT_BASE_DIR
    docker-compose \
      up \
      --force-recreate \
      --build
  )
}
