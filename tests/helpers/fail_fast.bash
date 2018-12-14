#!/usr/bin/env bash

fail_fast() {
  [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skipping; fail-fast is enabled"
}

mark_test_as_complete() {
  [ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip
}
