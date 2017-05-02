#!/bin/bash

readonly META_IMAGE_COUNT=built-image-count
readonly META_IMAGE_TAG_IDX=built-image-tag-
readonly META_IMAGE_TAG=built-image-tag-

# Read agent metadata for the plugin
function plugin_get_metadata() {
  local key="docker-compose-plugin-$1"
  plugin_prompt buildkite-agent meta-data get "$key"
  buildkite-agent meta-data get "$key"
}

# Write agent metadata for the plugin
function plugin_set_metadata() {
  local key="docker-compose-plugin-$1"
  local value="$2"
  plugin_prompt_and_must_run buildkite-agent meta-data set "$key" "$value"
}

# Gets a list of service / image pairs, each pair on a newline, delimited by space
function get_prebuilt_images_from_metadata() {
  local service="${1:-}"
  local image
  local count

  if ! count=$(plugin_get_metadata "$META_IMAGE_COUNT") ; then
    echo "SERVICE $service" >&2;
    if image="$(plugin_get_metadata "${META_IMAGE_TAG}${service}")" ; then
      echo "$service $image"
      return 0
    fi
  fi

  [[ $count -gt 0 ]] || return 0

  for i in $(seq 0 $((count-1))) ; do
    service="$(plugin_get_metadata "${META_IMAGE_TAG_IDX}${i}")"
    image="$(plugin_get_metadata "${META_IMAGE_TAG}${service}")"
    echo "$service $image"
    i=$((i+1))
  done
}

# Helper for use with get_prebuilt_images_from_metadata
function get_services_from_map() {
  for ((n=1;n<$#;n++)) ; do
    if (( $((n % 2)) == 1 )) ; then
      echo ${!n}
    fi
  done
}