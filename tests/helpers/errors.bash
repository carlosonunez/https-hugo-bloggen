#!/usr/bin/env bash
show_additional_error_info_when_test_fails() {
  >&2 echo "Test failed with status code $status".
  if [ ! -z "$output" ]
  then
    >&2 echo "Output: $output"
  fi
}
