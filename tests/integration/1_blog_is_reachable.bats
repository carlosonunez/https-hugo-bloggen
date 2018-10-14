#!/usr/bin/env bats
load ../helpers/errors

teardown(){
  if [ "$BATS_TEST_NUMBER" -eq ${#BATS_TEST_NAMES[@]} ]; then
    make terraform_destroy
  fi
  show_additional_error_info
}

@test "Ensure that our blog is visible online" {
  run make deploy_infrastructure
  [ "$status" -eq 0 ]

  blog_uri=$(make terraform_output VARIABLE_TO_GET=route53_dns_address)
  run curl --location -vvv "https://blog_uri"
  show_additional_error_info
  [ "$status" -eq 0 ]
}
