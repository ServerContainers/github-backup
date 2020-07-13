github-backup - simple github backup tool
=========================================

Docker Container to be used to Backup GitHub Repositories

Automate using `cron` or `systemd` etc.

## Usage

```
mkdir repos
docker run -ti -v "$PWD:/data" servercontainers/github-backup github-backup.sh ServerContainers /data/repos/
```
