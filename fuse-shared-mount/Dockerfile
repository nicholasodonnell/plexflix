FROM alpine:latest

ENV MOUNT_DIR=/Users

# https://github.com/docker/for-mac/issues/3431#issuecomment-545267759
CMD nsenter -t $(pgrep docker-init) -m -- mount --verbose --make-shared ${MOUNT_DIR}
