#!/bin/bash

# Enable script to exit on error and print commands and their arguments as they are executed.
set -euxo pipefail

docker compose up -d --force-recreate

echo "Process completed successfully."