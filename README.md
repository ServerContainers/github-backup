github-backup - simple github backup tool
=========================================

Docker Container to be used to Backup GitHub Repositories

It's based on the [_/alpine](https://registry.hub.docker.com/_/alpine/) Image (3.12)

View in GitHub Registry [ghcr.io/servercontainers/github-backup](https://ghcr.io/servercontainers/github-backup)

View in GitHub [ServerContainers/github-backup](https://github.com/ServerContainers/github-backup)

_currently tested on: x86_64, arm64, arm_


Automate using `cron` or `systemd` etc.

## IMPORTANT!

In March 2023 - Docker informed me that they are going to remove my 
organizations `servercontainers` and `desktopcontainers` unless 
I'm upgrading to a pro plan.

I'm not going to do that. It's more of a professionally done hobby then a
professional job I'm earning money with.

In order to avoid bad actors taking over my org. names and publishing potenial
backdoored containers, I'd recommend to switch over to my new github registry: `ghcr.io/servercontainers`.

## Build & Versions

You can specify `DOCKER_REGISTRY` environment variable (for example `my.registry.tld`)
and use the build script to build the main container and it's variants for _x86_64, arm64 and arm_

You'll find all images tagged like `a3.15.0-gMonFeb2219063620210100` which means `a<alpine version>-g<github-backup-latest-commit-date>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

To build a `latest` tag run `./build.sh release`

## Changelogs

* 2023-03-20
    * github action to build container
    * implemented ghcr.io as new registry
* 2023-03-19
    * switched from docker hub to a build-yourself container
    * new way of multiarch build
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
docker run -ti --rm -v "$PWD:/data" ghcr.io/servercontainers/github-backup github-backup.sh ServerContainers /data/repos/

# backup MarvAmBass repositories
docker run -ti --rm -v "$PWD:/data" ghcr.io/servercontainers/github-backup github-backup.sh MarvAmBass /data/repos/

# backup MarvAmBass starred repositories in special folder
mkdir -p repos/MarvAmBass.stars
docker run -ti --rm -v "$PWD:/data" -e 'TAB=stars' ghcr.io/servercontainers/github-backup github-backup.sh MarvAmBass /data/repos/MarvAmBass.stars

```
