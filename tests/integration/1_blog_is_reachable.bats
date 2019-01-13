#!/usr/bin/env bats
load ../helpers/errors
load ../helpers/fail_fast
load ../helpers/html

check_for_blog_url() {
  test "$HUGO_BASE_URL"
}

setup() {
  enable_fail_fast_mode
  if ! check_for_blog_url
  then
    >&2 echo "ERROR: Please provide a blog URL to test against."
    return 1
  fi
}

teardown() {
  show_additional_error_info_when_test_fails
  disable_fail_fast_mode
}

@test "Blog is reachable at $HUGO_BASE_URL" {
  run curl --silent -o /dev/null --write-out "%{http_code}" "$HUGO_BASE_URL"
  [ "$status" -eq 0 ]
  [ "$output" == 200 ]
}
