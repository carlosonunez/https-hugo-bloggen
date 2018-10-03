#!/usr/bin/env bats

@test "Ensure that our blog post renders" {
  run ./scripts/render_hugo_blog.sh
  >&2 echo "ERROR: Test failed: $output"
  [ "$status" -eq 0 ]
}
