DOCKER_COMPOSE_FILE=

main () {
  create_docker_compose_file
  build_application
  build_container_image
  push_container_image
  create_terraform
  apply_terraform
}

create_docker_compose_file() {
  DOCKER_COMPOSE_FILE=$PROJECT_BASE_DIR/dest/docker-compose-build-image.yaml
  cat <<EOF > "$DOCKER_COMPOSE_FILE"
version: '3'

services:
  {{#each services as |service| ~}}
  {{define "datasource" service.datasource ~}}
  {{define "db_migration_service_name" (concat (hyphen datasource.name) '-migrate') ~}}
  {{db_migration_service_name}}:
    build:
      context: ./{{db_migration_service_name}}
      dockerfile: Dockerfile.local-dev
    image: gcr.io/{{hyphen project.group}}/{{db_migration_service_name}}

  tutorial-api:
    build:
      context: ./{{hyphen service.name}}
      dockerfile: Dockerfile.local-dev
    image: gcr.io/{{hyphen project.group}}/{{hyphen service.name}}
  {{/each}}
EOF
}

build_application() {
  {{#each services as |service| ~}}
  {{define "datasource" service.datasource ~}}
  (cd $PROJECT_BASE_DIR/dest/{{hyphen datasource.name}}-migrate
    ./gradlew build
  )
  (cd $PROJECT_BASE_DIR/dest/{{hyphen service.name}}
    ./gradlew build
  )
  {{/each}}
}

build_container_image() {
  docker-compose \
    --file "$DOCKER_COMPOSE_FILE" \
    build
}

push_container_image() {
  docker-compose \
    --file "$DOCKER_COMPOSE_FILE" \
    push
}

create_terraform() {
  echo create_terraform
}

apply_terraform() {
  echo apply_terraform
}
