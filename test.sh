#!/bin/sh
# automated functional test for the github-backup container
# builds the image and verifies the backup script actually clones a public
# github repo (real git objects land on disk). all test data is created INSIDE
# the container - nothing is bind-mounted from the host.
set -eu

IMAGE=github-backup-test
NAME=github-backup-test-run

# a tiny, well-known public repo that needs no auth
TEST_REPO=octocat/Hello-World
BACKUP_DIR=/data/repos

FAILED=0
fail() {
  echo "FAIL: $*" >&2
  FAILED=1
}

cleanup() {
  echo ">> cleanup: removing container $NAME"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo ">> building image $IMAGE"
docker build -t "$IMAGE" .

echo ">> (re)starting container $NAME"
docker rm -f "$NAME" >/dev/null 2>&1 || true
# it's a batch tool, not a server - keep the container alive so we can drive
# the backup script via docker exec and inspect its output afterwards
docker run -d --name "$NAME" "$IMAGE" sleep 900

echo ">> assert: container is running"
docker ps --format '{{.Names}}' | grep -q "^${NAME}$" \
  && echo "ok - container running" || fail "container not running"

echo ">> assert: git is installed"
if docker exec "$NAME" sh -c 'command -v git' >/dev/null 2>&1; then
  echo "ok - git present"
else
  fail "git not found in container"
fi

echo ">> assert: backup script is on PATH and executable"
if docker exec "$NAME" sh -c 'command -v github-backup.sh' >/dev/null 2>&1; then
  echo "ok - github-backup.sh on PATH"
else
  fail "github-backup.sh not found on PATH"
fi

echo ">> assert: script prints usage and exits non-zero without args"
if docker exec "$NAME" github-backup.sh >/dev/null 2>&1; then
  fail "script exited 0 with no args (expected usage error)"
else
  echo "ok - script rejects missing args"
fi

echo ">> assert: real backup - clone public repo $TEST_REPO"
docker exec "$NAME" mkdir -p "$BACKUP_DIR"
if docker exec "$NAME" github-backup.sh "$TEST_REPO" "$BACKUP_DIR"; then
  echo "ok - backup script ran"
else
  fail "backup script returned non-zero"
fi

# the single-repo path clones https://github.com/<repo> into <repo>.git
CLONE_DIR="$BACKUP_DIR/$TEST_REPO.git"

echo ">> assert: backup produced a git repo with objects"
if docker exec "$NAME" test -d "$CLONE_DIR/.git"; then
  echo "ok - clone dir exists: $CLONE_DIR"
else
  fail "expected clone dir not found: $CLONE_DIR"
fi

echo ">> assert: cloned repo has a valid HEAD commit"
HEAD_SHA=$(docker exec "$NAME" git -C "$CLONE_DIR" rev-parse HEAD 2>/dev/null || true)
if echo "$HEAD_SHA" | grep -qE '^[0-9a-f]{40}$'; then
  echo "ok - HEAD commit: $HEAD_SHA"
else
  fail "could not resolve HEAD in backup (got: '$HEAD_SHA')"
fi

echo ">> assert: cloned repo has real git objects on disk"
if docker exec "$NAME" sh -c "git -C '$CLONE_DIR' log --oneline | head -n1" | grep -q .; then
  echo "ok - git history present in backup"
else
  fail "no git history found in backup"
fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  echo "SOME TESTS FAILED"
  exit 1
fi
