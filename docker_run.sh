#!/usr/bin/env zsh
# docker_run.sh
# Run a Void Linux container for Mac development
# Written by rh 2026-09-07

set -e

IMAGE="rh-linux-install-dev"
CONTAINER="rh-install-dev"
PLATFORM="linux/amd64"

if [[ $(uname) != "Darwin" ]]; then
  echo "This command only runs on macOS" >&2
  exit 1
fi

# Build the development image.
echo "Building $IMAGE..."
docker build \
  --platform "$PLATFORM" \
  -t "$IMAGE" \
  .

# Create the container if it doesn't already exist.
if ! docker container inspect "$CONTAINER" >/dev/null 2>&1; then
  echo "Creating container $CONTAINER..."

  docker run -d \
    --platform "$PLATFORM" \
    --name "$CONTAINER" \
    -v "$PWD:/workspace" \
    "$IMAGE" \
    sleep infinity
fi

# Make sure the container is running.
if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]]; then
  echo "Starting container $CONTAINER..."
  docker start "$CONTAINER" >/dev/null
fi

# Open an interactive shell inside the container.
docker exec -it "$CONTAINER" /bin/sh
