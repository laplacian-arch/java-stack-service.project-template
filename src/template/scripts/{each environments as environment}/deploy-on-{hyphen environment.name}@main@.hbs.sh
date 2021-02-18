{{define 'deployment_components' (unique (map environment.deployments '@it.component')) ~}}
{{define 'deployments_with_migration' (unique (filter environment.deployments '@it.initial_data')) ~}}
DEPLOYMENT_BASE_DIR=$PROJECT_BASE_DIR/dest/environments/{{hyphen environment.name}}
COMPONENT_BASE_DIR=$PROJECT_BASE_DIR/dest/components

main () {
  build_components
  build_migration_tasks
  deploy_containers
}

build_components() {
  echo "Building deployable components..."
  {{#each deployment_components as |component| ~}}
  {{#if component.custom_built ~}}
  build_{{lower-snake component.name}}
  {{/if}}
  {{/each}}
}

build_migration_tasks() {
  echo "Building data migration tasks..."
  {{#each deployments_with_migration as |deployment| ~}}
  build_{{lower-snake deployment.name}}_migration
  {{/each}}
}

deploy_containers() {
  echo "Deploying application modules..."
  (cd $DEPLOYMENT_BASE_DIR
    docker-compose rm \
      --force

    docker-compose up \
      --force-recreate \
      --build
  )
}
