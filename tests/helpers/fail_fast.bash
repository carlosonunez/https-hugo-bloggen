#!/usr/bin/env bash

enable_fail_fast_mode() {
  [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skipping; fail-fast is enabled"
}

disable_fail_fast_mode() {
  [ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip
}
