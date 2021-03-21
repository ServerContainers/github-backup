github-backup - simple github backup tool
=========================================

Docker Container to be used to Backup GitHub Repositories

Automate using `cron` or `systemd` etc.


## Changelogs

* 2021-03-21
    * support for multiple pages of github profiles
* 2020-11-05
    * multiarch build

## Usage

```
mkdir repos
docker run -ti --rm -v "$PWD:/data" servercontainers/github-backup github-backup.sh ServerContainers /data/repos/
```
