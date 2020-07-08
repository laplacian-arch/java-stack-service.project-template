{{define 'is_local_dev' true ~}}
DOCKER_COMPOSE_FILE=

main () {
  create_docker_compose_file
  {{#if is_local_dev ~}}
  build_container_images
  {{/if}}
  run
}

{{#if is_local_dev ~}}
build_container_images() {
  {{#each datasources as |datasource| ~}}
  (cd $PROJECT_BASE_DIR/dest/{{hyphen datasource.name}}-migrate
    ./gradlew build
  )
  {{/each}}
  {{#each services as |service| ~}}
  (cd $PROJECT_BASE_DIR/dest/{{hyphen service.name}}
    ./gradlew build
  )
  {{/each}}
}
{{/if}}

create_docker_compose_file() {
  DOCKER_COMPOSE_FILE=$PROJECT_BASE_DIR/dest/docker-compose.yaml
  cat <<EOF > "$DOCKER_COMPOSE_FILE"
version: '3'
networks:
  frontend:
  backend:

services:
  {{#each datasources as |datasource| ~}}
  {{datasource.container_name}}:
    image: {{datasource.container_image}}
    container_name: {{datasource.container_name}}
    ports:
    - '{{printf "%1$s:%1$s" datasource.port}}'
    expose:
    - '{{datasource.port}}'
    environment:
    - 'POSTGRES_USER={{datasource.db_user}}'
    - 'POSTGRES_PASSWORD={{datasource.db_password}}'
    - 'POSTGRES_DB={{datasource.db_name}}'
    networks:
    - backend

  {{datasource.container_name}}-migrate:
    build:
      context: ./{{hyphen datasource.name}}-migrate
      {{#if is_local_dev ~}}
      dockerfile: Dockerfile.local-dev
      {{/if}}
    container_name: {{datasource.container_name}}-migrate
    environment:
    - 'DATASOURCE_URL={{datasource.jdbc_url}}'
    - 'DATASOURCE_USER={{datasource.db_user}}'
    - 'DATASOURCE_PASS={{datasource.db_password}}'
    networks:
    - backend
  {{/each}}

  {{#each services as |service| ~}}
  {{define 'datasource' service.datasource ~}}
  {{hyphen service.name}}:
    build:
      context: ./{{hyphen service.name}}
      {{#if is_local_dev ~}}
      dockerfile: Dockerfile.local-dev
      {{/if}}
    container_name: {{hyphen service.name}}
    ports:
    - '8080:8080'
    expose:
    - '8080'
    environment:
    - 'DATASOURCE_URL=r2dbc:pool:postgresql://{{hyphen datasource.name}}:5432/{{datasource.db_name}}'
    - 'DATASOURCE_USER={{datasource.db_user}}'
    - 'DATASOURCE_PASS={{datasource.db_password}}'
    networks:
    - backend
  {{/each}}
EOF
}

run() {
  docker-compose \
    --file "$DOCKER_COMPOSE_FILE" \
    up \
    --force-recreate \
    --build
}