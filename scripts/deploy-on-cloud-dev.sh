#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"


OPT_NAMES='hv-:'

ARGS=
HELP=
VERBOSE=


# @main@
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
EOF
}

build_application() {
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
# @main@

# @+additional-declarations@
# @additional-declarations@

parse_args() {
  while getopts $OPT_NAMES OPTION;
  do
    case $OPTION in
    -)
      case $OPTARG in
      help)
        HELP='yes';;
      verbose)
        VERBOSE='yes';;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='yes';;
    v) VERBOSE='yes';;
    esac
  done
  ARGS=$@
}

show_usage () {
cat << 'END'
Usage: ./scripts/deploy-on-cloud-dev.sh [OPTION]...
  -h, --help
    Displays how to use this command.
  -v, --verbose
    Displays more detailed command execution information.
END
}

parse_args "$@"

! [ -z $VERBOSE ] && set -x
! [ -z $HELP ] && show_usage && exit 0
main