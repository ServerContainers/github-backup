github-backup - simple github backup tool
=========================================

Docker Container to be used to Backup GitHub Repositories

Automate using `cron` or `systemd` etc.


## Changelogs

* 2021-06-08
    * support for starred repos of a user/profile
* 2021-03-21
    * support for multiple pages of github profiles
* 2020-11-05
    * multiarch build

## Environment Variables

- TAB
    - default: `repositories`
    - selects tab to fetch repositories from. for starred repos of a profile set this to: `stars`

## Usage

```
mkdir repos
# backup ServerContainers repos
docker run -ti --rm -v "$PWD:/data" servercontainers/github-backup github-backup.sh ServerContainers /data/repos/

# backup MarvAmBass repositories
docker run -ti --rm -v "$PWD:/data" servercontainers/github-backup github-backup.sh MarvAmBass /data/repos/

# backup MarvAmBass starred repositories in special folder
mkdir -p repos/MarvAmBass.stars
docker run -ti --rm -v "$PWD:/data" -e 'TAB=stars' servercontainers/github-backup github-backup.sh MarvAmBass /data/repos/MarvAmBass.stars

```
