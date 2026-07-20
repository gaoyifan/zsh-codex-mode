#!/usr/bin/env zsh

set -euo pipefail

demo_dir=${0:A:h}
repo_dir=${demo_dir:h}
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-codex-mode-demo.XXXXXX")
work_dir=$temp_dir/work
trap 'rm -rf -- "$temp_dir"' EXIT

mkdir "$work_dir"
cp -R "$demo_dir/fixture/." "$work_dir/"
(
  cd "$work_dir"
  git init -q -b main
  git config user.name Demo
  git config user.email demo@example.com
  git add .
  GIT_AUTHOR_DATE=2026-01-01T00:00:00Z \
    GIT_COMMITTER_DATE=2026-01-01T00:00:00Z \
    git commit -qm "Initial commit"
  git apply "$demo_dir/changes.patch"
)

export PATH="$demo_dir:$PATH"

sed \
  -e "s|__DEMO_ROOT__|$repo_dir|g" \
  -e "s|__DEMO_WORK__|$work_dir|g" \
  "$demo_dir/demo.tape" >"$temp_dir/demo.tape"

cd "$repo_dir"
vhs "$temp_dir/demo.tape"
