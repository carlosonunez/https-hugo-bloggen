#!/usr/bin/env bash
show_additional_error_info_when_test_fails() {
  >&2 echo -e "Test failed with status code $status".
  if [ ! -z "$output" ]
  then
    >&2 echo "Output: $output"
  else
    >&2 echo "No output was generated."
  fi
}
