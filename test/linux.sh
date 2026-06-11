#!/usr/bin/env bash
# test/linux.sh — local Linux test bed for the dotfiles, faithful to the Coder
# devbox. Bind-mounts this repo at /home/coder/.dotfiles so host edits reflect
# live inside the container — mirroring the real `git pull` Stow workflow, no
# rebuild needed between iterations.
#
#   test/linux.sh build        # build the image (once; re-run after Dockerfile edits)
#   test/linux.sh up           # start the persistent container (idempotent)
#   test/linux.sh sh           # interactive login shell inside it
#   test/linux.sh exec CMD...  # run a command (login shell) inside it
#   test/linux.sh down         # stop + remove it
#   test/linux.sh reset        # down + up
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE=dotfiles-linux-test
NAME=dotfiles-linux

cmd="${1:-sh}"; shift || true
case "$cmd" in
  build)
    docker build -f "$REPO/test/Dockerfile.linux" -t "$IMAGE" "$REPO/test"
    ;;
  up)
    if docker inspect "$NAME" >/dev/null 2>&1; then
      docker start "$NAME" >/dev/null
    else
      docker run -d --name "$NAME" \
        -v "$REPO":/home/coder/.dotfiles \
        "$IMAGE" sleep infinity >/dev/null
    fi
    echo "up: $NAME  (repo bind-mounted at /home/coder/.dotfiles)"
    ;;
  sh)
    docker exec -it "$NAME" bash -l
    ;;
  exec)
    docker exec -i "$NAME" bash -lc "$*"
    ;;
  down)
    docker rm -f "$NAME" >/dev/null 2>&1 || true
    echo "down: $NAME"
    ;;
  reset)
    "$0" down; "$0" up
    ;;
  *)
    echo "usage: test/linux.sh {build|up|sh|exec|down|reset}" >&2
    exit 2
    ;;
esac
