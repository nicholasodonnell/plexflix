<img src="logo/logo.png" />

**Plexflix** is a personal media managing and streaming solution for Plex libraries hosted on Google Drive.

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
2. Create a `.env` file using [`.env.example`](.env.example) as a reference.
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

## FAQ

If you get an error such as `..is mounted on /Users but it is not a shared mount...` run `make fuse-shared-mount dir=/Users` where `dir` is your root directory.
