#!/usr/bin/env bats

@test "Ensure that our blog renders" {
  run ./scripts/render_hugo_blog.sh
  cat <<-EOF
Test failed.

Output
======
$output
EOF
  [ "$status" -eq 0 ]
}
