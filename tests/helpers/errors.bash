#!/usr/bin/env bash
show_additional_error_info() {
  cat <<-EOF
Test failed.

Output
======
$output
EOF
}
