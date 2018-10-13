#!/usr/bin/env bats
show_additional_error_info() {
  cat <<-EOF
Test failed.

Output
======
$output
EOF
}

@test "Ensure that our blog renders locally" {
  run ./scripts/render_hugo_blog.sh
  show_additional_error_info
  [ "$status" -eq 0 ]
}

@test "Ensure that we can see new blog posts locally" {
  run ./scripts/render_hugo_blog.sh 'my_new_post'
  show_additional_error_info
  [ "$status" -eq 0 ]
}
