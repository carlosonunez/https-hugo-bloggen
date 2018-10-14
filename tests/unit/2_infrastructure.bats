#!/usr/bin/env bats
load ../helpers/errors

@test "Ensure that we can generate a plan" {
  run make terraform_plan
  show_additional_error_info
  [ "$status" -eq 0 ]
}
