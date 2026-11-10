#!/usr/bin/env bash
# Read-only scope collector for a code review.
# Usage: scripts/scope.sh [repo_path] [base_ref]
#   repo_path  defaults to the current directory
#   base_ref   defaults to origin/HEAD, then origin/main, then origin/master
# Makes no changes to the working tree. The only network call is `git fetch`.
set -u

repo="${1:-.}"
cd "$repo" || { echo "cannot enter $repo" >&2; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not a git repository: $repo" >&2; exit 2; }

echo "== Repository"
echo "path:    $(pwd)"
echo "remote:  $(git remote get-url origin 2>/dev/null | sed -E 's#//[^/@]*@#//#')"
echo "branch:  $(git branch --show-current)"
echo "dirty:   $(git status --porcelain | wc -l) changed file(s)"

echo
echo "== Fetching remote (read-only)"
GIT_TERMINAL_PROMPT=0 git fetch --all --prune -q 2>&1 | tail -2 || true

base="${2:-}"
if [ -z "$base" ]; then
  base="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  [ -z "$base" ] && for c in origin/main origin/master; do
    git rev-parse --verify -q "$c" >/dev/null && { base="$c"; break; }
  done
fi
[ -z "$base" ] && { echo "no base ref found; pass one as the second argument" >&2; exit 2; }

echo
echo "== Base: $base"
echo "ahead of base:  $(git rev-list --count "$base"..HEAD)"
echo "behind base:    $(git rev-list --count HEAD.."$base")"
echo "unpushed:       $(git log --oneline '@{u}..' 2>/dev/null | wc -l)"

echo
echo "== Commits on this branch (not on base)"
git log --format='%h %ad %an  %s' --date=short "$base"..HEAD | head -30

echo
echo "== Changed files vs base (three-dot)"
git diff --stat "$base"...HEAD | tail -40

echo
echo "== Other promotion branches on the remote"
git branch -r | grep -E 'origin/(main|master|develop|test|staging|prod|production)$' || echo "(none found)"

echo
echo "== Test layout (names only)"
git ls-files | grep -i -E '(^|/)(tests?|__tests__|spec)(/|$)|(^|/)(test_.*|.*_test|.*\.test|.*\.spec)\.[a-z]+$' | head -40
echo
echo "== Test runner config present"
git ls-files | grep -i -E '(^|/)(pytest\.ini|tox\.ini|setup\.cfg|pyproject\.toml|jest\.config\.[a-z]+|package\.json|conftest\.py|Makefile)$' | head -20

echo
echo "== Dependency manifests and lock files"
git ls-files | grep -i -E '(^|/)(requirements[^/]*\.txt|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Pipfile\.lock|poetry\.lock|go\.sum|Cargo\.lock|pom\.xml|build\.gradle)$' | head -20

echo
echo "== Per-environment config files (candidates for drift checks)"
git ls-files | grep -i -E '(^|/)(dev|test|staging|stage|prod|production|sandbox|sbx[a-z-]*)\.(json|ya?ml|toml|env)$' | head -40

echo
echo "== Done. Nothing was modified."
