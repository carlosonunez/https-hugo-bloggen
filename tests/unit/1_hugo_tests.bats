#!/usr/bin/env bats
load ../helpers/errors
load ../helpers/fail_fast

setup() {
  fail_fast
  expected_post_element='<h2 class="post-title"><a href="/post/test_post/">My new post</a></h2>'
  expected_title_rss_link='<link href="https://test.blog.carlosnunez.me:8080/index.xml" rel="alternate" type="application/rss+xml" title="Test Title" />'
  expected_description_element='<h2 class="blog-description">Test Description</h2>'
}

teardown() {
  show_additional_error_info_when_test_fails
  mark_test_as_complete
}

@test "Ensure that the local Hugo container starts" {
  run nc -z localhost 8080
  [ "$status" -eq 0 ]
}

@test "Ensure that new blog posts is in the post tree" {
  run curl --output /dev/null \
    --silent \
    --location \
    --write-out '%{http_code}' \
    "http://localhost:8080/post/test_post"
  [ "$status" -eq 0 ]
  [ "$output" == "200" ]
}

@test "Ensure that new blog posts show up in the feed" {
  run curl --silent "http://localhost:8080" | grep "$expected_post_element"
  [ "$status" -eq 0 ]
}

@test "Ensure that the title shows up" {
  run curl --location "http://localhost:8080/" | grep "$expected_title_rss_link"
  [ "$status" -eq 0 ]
}

@test "Ensure that our description shows up" {
  run curl --location "http://localhost:8080/" | grep "$expected_description_element"
  [ "$status" -eq 0 ]
}
