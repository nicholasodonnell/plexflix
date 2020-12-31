<img src="logo/logo.png" />

**Plexflix** is a dockerized personal media managing and streaming solution for Plex libraries hosted on Google Drive.

### Requirements

- [Docker Community Edition](https://www.docker.com/community-edition)
- [Docker Compose](https://docs.docker.com/compose/)
- [GNU make](https://www.gnu.org/software/make/)
- [Google Drive](https://drive.google.com/)

### Services

- **Plex** - Manages and streams media.
- **Plexdrive** - Mounts a read-only, Google Drive account as a fuse filesystem that is optimized for media playback.

## Installation

1. Install fuse on your system (optional).
2. Create a `.env` file using [`.env.example`](.env.example) as a reference: `cp -n .env{.example,}`.
3. Build the Plexflix docker images by running `make build`.
4. Create the Plexdrive configuration files by running `make plexdrive-setup` and following the prompts.
5. Create a `.mountcheck` file on Google Drive. This file will tell Plexflix your mount is healthy.

## Setup

When running the Plexflix for the first time, after doing a `make up`:

1. Configure Plex Media Server by visiting `http://<YOUR_IP>:<PLEX_MEDIA_SERVER_PORT>/web`.

## Usage

To bring up Plexflix:

```
make up
```

To bring down Plexflix:

```
make down
```

To restart a service:

```
make restart service="<service>"
```

To stop a service:

```
make stop service="<service>"
```

To view logs:

```
make logs [service="<service>"] [file=/path/to/log/file]
```

To (re)build one or more services

```
make build [service="<service>"]
```

To clean the Plexflix project (will require another `make build`):

```
make clean
```

To list running services:

```
make ps
```

To see the health of your Plexdrive mount:

```
make mount-health
```

## ENV Options

| Option                                      | Description                                                                                                                                                                                                                               |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PROJECT_NAME`                              | The docker compose project name.                                                                                                                                                                                                          |
| `USER`                                      | `PUID` of user for volume mounts. Ensures any volume directories on the host are owned by the same user to avoid any permissions issues.                                                                                                  |
| `GROUP`                                     | `PGID` of user for volume mounts. Ensures any volume directories on the host are owned by the same user to avoid any permissions issues.                                                                                                  |
| `TIMEZONE`                                  | Timezone to use.                                                                                                                                                                                                                          |
| `LIBRARIES_MOUNT_PATH`                      | Path on the host to mount Google Drive libraries.                                                                                                                                                                                         |
| `PLEX_COMPANION_PORT`                       | Host port for the Plex companion.                                                                                                                                                                                                         |
| `PLEX_DLNA_SERVER_TCP_PORT`                 | Host port for Plex DLNA server (TCP).                                                                                                                                                                                                     |
| `PLEX_DLNA_SERVER_UDP_PORT`                 | Host port for Plex DLNA server (UDP).                                                                                                                                                                                                     |
| `PLEX_MEDIA_SERVER_PORT`                    | Host port for Plex Media Server.                                                                                                                                                                                                          |
| `PLEX_NETWORK_DISCOVERY_PORT_1`             | Host port for Plex network discovery (#1).                                                                                                                                                                                                |
| `PLEX_NETWORK_DISCOVERY_PORT_2`             | Host port for Plex network discovery (#2).                                                                                                                                                                                                |
| `PLEX_NETWORK_DISCOVERY_PORT_3`             | Host port for Plex network discovery (#3).                                                                                                                                                                                                |
| `PLEX_NETWORK_DISCOVERY_PORT_4`             | Host port for Plex network discovery (#4).                                                                                                                                                                                                |
| `PLEX_ROKU_COMPANION_PORT`                  | Host port for Plex Roku companion.                                                                                                                                                                                                        |
| `PLEXDRIVE_CONFIG_PATH`                     | Host location for Rclone configuration files.                                                                                                                                                                                             |
| `PLEXDRIVE_ROOT_FOLDER_ID`                  | Google Drive folder ID to be treated as the root folder (use this to mount a sub directory).                                                                                                                                              |

## FAQ

If you get an error such as `..is mounted on /Users but it is not a shared mount...` run `make fuse-shared-mount dir=/Users` where `dir` is your root directory.

If you get an error such as `...mount: /host_mnt/dir: not mount point or bad option...` turn off `Use gRPC FUSE for file sharing` in your Docker preferences.
