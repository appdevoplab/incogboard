#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Privacy gate: fails if any release APK requests a network permission.
# Usage: tool/check_release_permissions.sh build/app/outputs/flutter-apk/*-release.apk
set -euo pipefail

AAPT2=$(ls -d "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/*/aapt2* | sort -V | tail -n 1)
FORBIDDEN='android.permission.INTERNET|android.permission.ACCESS_NETWORK_STATE|android.permission.ACCESS_WIFI_STATE'
status=0
for apk in "$@"; do
  perms=$("$AAPT2" dump permissions "$apk")
  echo "== $apk"
  echo "$perms" | grep -E "uses-permission" || true
  if echo "$perms" | grep -Eq "$FORBIDDEN"; then
    echo "FAIL: $apk requests a network permission" >&2
    status=1
  fi
done
exit $status
