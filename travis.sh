#!/bin/bash

# Fast fail the script on failures.
set -e

$(dirname -- "$0")/ensure_dartfmt.sh

# Run the tests.
pub run unittest

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --retry 2 \
    --exclude-test-files \
    test/all_test.dart
fi
