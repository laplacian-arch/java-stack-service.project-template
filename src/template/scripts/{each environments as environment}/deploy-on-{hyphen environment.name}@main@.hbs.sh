DEPLOYMENT_BASE_DIR=$PROJECT_BASE_DIR/dest/environments/{{hyphen environment.name}}
COMPONENT_BASE_DIR=$PROJECT_BASE_DIR/dest/components

main () {
  {{#each environment.deployments as |deployment| ~}}
  build_component_for_{{lower-snake deployment.name}}
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
