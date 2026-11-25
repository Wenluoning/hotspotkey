#!/usr/bin/env bash
#
# ci/build.sh —— GitHub Actions 上的完整构建流程
#
# 支持两种仓库布局：
#   A) 仓库根目录就是工程（HotspotKey/ 存在）
#   B) 仓库里只有一个 source.zip（本仓库采用这种）
#
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

echo "== 工作目录: $ROOT"

if [ -f source.zip ] && [ ! -d HotspotKey ]; then
  echo "== 发现 source.zip，解压源码"
  rm -rf _src
  mkdir -p _src
  unzip -q -o source.zip -d _src
  cp -R _src/. .
  rm -rf _src
export SOURCE_FROM_ZIP=1
fi

if [ ! -d HotspotKey ]; then
  echo "!! 找不到 HotspotKey/ 目录，源码没到位"
  ls -la
  exit 1
fi

echo "== 目录结构"
ls -la
echo "--"
find HotspotKey -name '*.swift' | wc -l | xargs echo "Swift 文件数:"

echo "== 生成工程 / scheme / 图标"
python3 scripts/gen_pbxproj.py
python3 scripts/gen_icon.py
ls -l HotspotKey.xcodeproj/xcshareddata/xcschemes/

echo "== 结构自检"
python3 scripts/selfcheck.py

echo "== 编译并打包 ipa"
bash scripts/build_ipa.sh --unsigned

echo "== 产物"
ls -lh dist/
find dist -name '*.ipa' -type f
