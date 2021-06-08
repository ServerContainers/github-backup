#!/bin/sh

[ $# -ne 2 ] && >&2 echo "usage: script.sh <github_user> <dir_to_store_repos>" && exit 1



gh_user="$1"
backup_dir="$2"

repos=""

find_repo() {
  url="$1"
  page=$(wget -O - "$url" 2>/dev/null)
  reposFound=$(echo "$page" | sed -n '/[Rr]epository"/s/.*href="\/\([^"]\+\).*/\1/p' | sort | uniq)
  next_url=$(echo "$page" | sed -n '/?after/s/.*href="\([^"]\+\).*/\1/p' | grep .)

  if [ "x$reposFound" != "x" ]; then
    echo "found repos..."
    if [ "x$repos" = "x" ]; then
      repos="$reposFound"
    else
      repos="$repos
$reposFound"
    fi
  fi

  if [ "x$next_url" != "x" ]; then
    echo "found new page..."
    find_repo "$next_url"
  fi
}


[ ! -d "$backup_dir" ] && >&2 echo "usage: script.sh <github_user> <dir_to_store_repos> - no directory to store backups in" && exit 1

gh_url="https://github.com/"

if echo "$gh_user" | grep '/' 2>/dev/null >/dev/null; then
  echo "given single repo to backup..."
  repos="$gh_user"
else
  if [ "x$TAB" == "x" ]; then
    TAB="repositories"
  fi
  echo "using tab: $TAB"

  find_repo "$gh_url$gh_user""?tab=$TAB"
  echo "list of repos:"
  echo "$repos"
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
