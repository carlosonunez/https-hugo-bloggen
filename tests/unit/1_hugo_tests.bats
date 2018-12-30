#!/usr/bin/env bats
load ../helpers/errors
load ../helpers/fail_fast
load ../helpers/html

setup() {
  enable_fail_fast_mode
  LOCAL_HUGO_INSTANCE_HOSTNAME=hugo
  LOCAL_HUGO_INSTANCE_PORT=8080
  LOCAL_HUGO_INSTANCE_URL="http://${LOCAL_HUGO_INSTANCE_HOSTNAME}:${LOCAL_HUGO_INSTANCE_PORT}"
  expected_post_element='<h2 class="post-title"><a href="/post/test_post/">My new post</a></h2>'
  expected_title_rss_link='<link href="http://localhost:8080/index.xml" rel="alternate" type="application/rss+xml" title="Test Title" />'
  expected_description_element='<h2 class="blog-description">Test Description</h2>'
}

teardown() {
  show_additional_error_info_when_test_fails
  disable_fail_fast_mode
}

@test "Ensure that the local Hugo container starts" {
  run nc -z "$LOCAL_HUGO_INSTANCE_HOSTNAME" "$LOCAL_HUGO_INSTANCE_PORT"
  [ "$status" -eq 0 ]
}

@test "Ensure that new blog posts is in the post tree" {
  run curl --output /dev/null \
    --silent \
    --location \
    --write-out '%{http_code}' \
    "${LOCAL_HUGO_INSTANCE_URL}/post/test_post"
  [ "$status" -eq 0 ]
  [ "$output" == "200" ]
}

@test "Ensure that new blog posts show up in the feed" {
  run find_element_in_hugo_blog "$expected_description_element" "$LOCAL_HUGO_INSTANCE_URL"
  [ "$status" -eq 0 ]
}

@test "Ensure that the title shows up" {
  run find_element_in_hugo_blog "$expected_title_rss_link" "$LOCAL_HUGO_INSTANCE_URL"
  [ "$status" -eq 0 ]
}

@test "Ensure that our description shows up" {
  run find_element_in_hugo_blog "$expected_description_element" "$LOCAL_HUGO_INSTANCE_URL"
  [ "$status" -eq 0 ]
}
