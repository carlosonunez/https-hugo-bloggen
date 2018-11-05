#!/usr/bin/env bats
load ../helpers/errors

setup() {
  if [ "$BATS_TEST_NUMBER" -eq 1 ];
  then
    >&2 echo "INFO: Creating test environment..."
    make deploy_infrastructure
  fi
  show_additional_error_info
}

teardown(){
  number_of_tests=$(cat $BATS_TEST_FILENAME | grep -Ec '^@test')
  >&2 echo "INFO: Destroying test environment..."
  if [ "$BATS_TEST_NUMBER" -eq "$number_of_tests" ]; then
    make terraform_destroy
  fi
  show_additional_error_info
}

@test "Ensure that we can get the URI for our blog" {
  make terraform_output VARIABLE_TO_GET=route53_dns_address
  show_additional_error_info
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "Ensure that our blog is visible online" {
  blog_uri=$(make terraform_output VARIABLE_TO_GET=route53_dns_address)
  run curl --location -vvv "$blog_uri"
  show_additional_error_info
  [ "$status" -eq 0 ]
}
