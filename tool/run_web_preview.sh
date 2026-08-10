#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$project_root"
exec env \
  PUB_HOSTED_URL=https://pub.flutter-io.cn \
  FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn \
  FLUTTER_SKIP_UPDATE_CHECK=true \
  /root/flutter/bin/flutter \
  run \
  -d web-server \
  --web-hostname=192.168.100.65 \
  --web-port=8091 \
  --web-launch-url=http://192.168.100.65:8091/ \
  --no-web-resources-cdn \
  --no-web-experimental-hot-reload \
  --no-devtools \
  --no-pub
