#!/bin/bash

./build.sh

if [ $? -ne 0 ]; then
  echo "Build failed. Exiting."
  exit 1
fi

./start.sh

if [ $? -ne 0 ]; then
  echo "Start failed. Exiting."
  exit 1
fi

echo "Update a restarting of services completed successfully."