#!/usr/bin/env bash

set -e
echo "Running https://taskfile.dev/install.sh ..."
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d
