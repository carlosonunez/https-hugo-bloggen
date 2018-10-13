#!/usr/bin/env bats
show_additional_error_info() {
  cat <<-EOF
Test failed.

Output
======
$output
EOF
}
@test "Ensure that we can generate a plan" {
  run make terraform_plan
  show_additional_error_info
  [ "$status" -eq 0 ]
}

@test "Ensure that a VPC was provisioned" {
  run make deploy_infrastructure
  show_additional_error_info
  [ "$status" -eq 0 ]

  make terraform_output VARIABLE_TO_GET=vpc_id
  show_additional_error_info
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}
