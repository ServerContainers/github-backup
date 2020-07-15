#!/bin/sh

[ $# -ne 2 ] && >&2 echo "usage: script.sh <github_user> <dir_to_store_repos>" && exit 1

gh_user="$1"

backup_dir="$2"

[ ! -d "$backup_dir" ] && >&2 echo "usage: script.sh <github_user> <dir_to_store_repos> - no directory to store backups in" && exit 1

gh_url="https://github.com/"

if echo "$gh_user" | grep '/' 2>/dev/null >/dev/null; then
  echo "given single repo to backup..."
  repos="$gh_user"
else
  repos=$(wget -O - "$gh_url$gh_user/" 2>/dev/null | sed -n '/"repository"/s/.*href="\/\([^"]\+\).*/\1/p')
fi

cd "$backup_dir"

for repo in $repos; do
  echo -n "repo: $gh_url$repo ... "
  if [ -d "$repo.git" ] && [ -d "$repo.git/.git" ]; then
    echo "pulling changes"
    cd "$repo.git"
    git pull
    cd - >/dev/null
  else
    echo "cloning repo"
    mkdir -p "$repo"
    rmdir "$repo"
    git clone "$gh_url$repo" "$repo.git"
  fi
  echo
done
