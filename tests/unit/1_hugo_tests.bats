#!/usr/bin/env bats
load ../helpers/errors
load ../helpers/fail_fast

setup() {
  fail_fast
}

teardown() {
  show_additional_error_info_when_test_fails
  mark_test_as_complete
}

@test "Ensure that the local Hugo container starts" {
  run nc -z localhost 8080
  [ "$status" -eq 0 ]
}

@test "Ensure that new blog posts show up" {
  run curl --output /dev/null \
    --silent \
    --write-out '%{http_code}' \
    "http://localhost:8080/post/test_post"
  [ "$status" -eq 0 ]
  [ "$output" == "200" ]
}
