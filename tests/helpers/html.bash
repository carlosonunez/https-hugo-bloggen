#!/usr/bin/env bash
find_element_in_hugo_blog() {
  element="${1?Please provide an element.}"
  url="${2?Please provide a URL.}"
  if ! grep -q "$element" <(curl --silent "$url")
  then
    >&2 echo "Element not found at $url: $element"
    return 1
  fi
  return 0
}

