#!/usr/bin/env bash
copy_blog_to_destination() {
  local src
  src="$1"
  if ! test -d "$LOCAL_DESTINATION_DIR"
  then mkdir -p "$LOCAL_DESTINATION_DIR" || return 1
  fi
  >&2 echo "INFO: Copying blog from '$src' to '$LOCAL_DESTINATION_DIR''"
  cp -Rv "${src}"/* "$LOCAL_DESTINATION_DIR/"
}

write_base_url_and_version() {
  cat >"$LOCAL_DESTINATION_DIR/.blog-metadata" <<-EOF
url: "$1"
version: "$2"
EOF
}

clean_dest() {
  rm -rf "$LOCAL_DESTINATION_DIR/*"
}

write_dockerfile_and_nginx_conf() {
  local url
  url="$(awk -F '/' '{print $NF}' <<< "$HUGO_BASE_URL")"
  sed "s;%HUGO_BASE_URL%;$url;g" ./infrastructure/local/nginx.conf.tmpl > "$LOCAL_DESTINATION_DIR/nginx.conf"
  cp ./infrastructure/local/Dockerfile "$LOCAL_DESTINATION_DIR/Dockerfile"
}

while read -r kv
do
  export "$kv"
done < <(egrep -Ev '^#' "$2" | xargs -0)
LOCAL_DESTINATION_PARENT_DIR="${LOCAL_DESTINATION_PARENT_DIR:-$HOME/Downloads}"
LOCAL_DESTINATION_DIR="${LOCAL_DESTINATION_PARENT_DIR}/blog"

clean_dest &&
  copy_blog_to_destination "$1" &&
  write_base_url_and_version "$HUGO_BASE_URL" "$VERSION" &&
  write_dockerfile_and_nginx_conf
