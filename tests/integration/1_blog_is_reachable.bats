#!/usr/bin/env bats
show_additional_error_info() {
  cat <<-EOF
Test failed.

Output
======
$output
EOF
}

teardown(){
  if [ "$BATS_TEST_NUMBER" -eq ${#BATS_TEST_NAMES[@]} ]; then
    make terraform_destroy
  fi
}

@test "Ensure that our blog is visible online" {
  run make deploy_infrastructure
  show_additional_error_info
  [ "$status" -eq 0 ]

  blog_uri=$(make terraform_output VARIABLE_TO_GET=route53_dns_address)
  run curl --location -vvv "https://blog_uri"
  show_additional_error_info
  [ "$status" -eq 0 ]
}
