#!/usr/bin/env bats
show_additional_error_info() {
  cat <<-EOF
Test failed.

Output
======
$output
EOF
}


@test "Ensure that we can deploy a static S3 bucket" {
  run make deploy_infrastructure
  show_additional_error_info
  [ "$status" -eq 0 ]
}
