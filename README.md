# NEAR RPC Speedup Project

## Introduction

The `near-rpc-speedup` project is designed to enhance the efficiency of NEAR protocol RPC nodes by introducing a cache storage mechanism. This added communication layer enables faster distribution of chunks among nodes, optimizing data exchange and improving overall network performance.

This repository contains deployment information on two critical services:
- [**Caching Proxies Cache**](https://github.com/aurora-is-near/caching-proxies-cache): A web service facilitating chunk retrieval.
- [**Caching Proxies Terminal**](https://github.com/aurora-is-near/caching-proxies-terminal): Manages the submission of chunks to the cache.

## Deployment Guide

This guide walks you through deploying these services on your machine (where the validators are located) and outlines the necessary setup changes.

### Services Overview

Both services are written in Go. The recommended deployment method is to build both services using the provided Dockerfiles and deploy them using `docker-compose`. Docker is required for this setup.

### Docker Deployment (Recommended)

Using Docker and `docker-compose` is the preferred method for deploying these services due to its simplicity and ease of use. Below is a brief explanation of the provided `docker-compose` configuration.

#### Docker Compose Configuration for Testnet

```yaml
services:
  cache:
    image: caching-proxies-cache:latest
    container_name: caching-proxies-cache-testnet
    pull_policy: never
    command:
      - "./app/app"
      - "-shard-prefix=shards"
      - "-shards-to-listen=1,2,3,4"
      - "-creds=config/testnet.creds"
      - "-server=nats://rpc-speedup-nats.testnet.aurora.dev"
    volumes:
      - ./config:/app/config
    restart: unless-stopped
    ports:
      - "1324:1324"

  terminal:
    image: caching-proxies-terminal:latest
    container_name: caching-proxies-terminal-testnet
    pull_policy: never
    command:
      - "./app/app"
      - "-server=nats://rpc-speedup-nats.testnet.aurora.dev"
      - "-submissions-verifier-host=https://rpc-speedup-verifier.testnet.aurora.dev/authenticate"
      - "-shard-prefix=shards"
    volumes:
      - ./config:/app/config
    restart: unless-stopped
    ports:
      - "1323:1323"
```

### Step-by-Step Setup Guide

1. **Clone the Repository and Create Config Directory**
   ```bash
   git clone https://github.com/aurora-is-near/near-rpc-speedup.git
   cd near-rpc-speedup
   mkdir -p config
   ```

2. **Build the Docker Images**
   Run the `build.sh` script to build the Docker images for `caching-proxies-cache` and `caching-proxies-terminal` services.
   ```bash
   ./build.sh
   ```

3. **Obtain Authentication Credentials**
   Request a `token` and `testnet.creds` file to authenticate with the validator and allow your cache instance to communicate with the NATS server. Contact Aurora Labs to obtain these credentials.

4. **Place the `testnet.creds` file**
   Place the `testnet.creds` file obtained from Aurora Labs into the `config` directory.

5. **Start the Services**
   Use the following command to start the services:
   ```bash
   docker-compose up -d --force-recreate
   # or
   ./start.sh
   ```

6. **Integrate with NEAR Validator Node**
   Modify the `config.json` of the NEAR node to include the following configuration:
   ```json
   "chunk_distribution_network": {
      "enabled": true,
      "uris": {
        "get": "http://caching-proxies-cache-testnet:1324/get",
        "set": "http://caching-proxies-terminal-testnet:1323/process?token=[token]"
      }
    }
   ```
   > **Important:** Replace `caching-proxies-cache-testnet` and `caching-proxies-terminal-testnet` with the actual hostname or IP address where the services are running. With Docker container setup, it could be as simple as `http://0.0.0.0`. Replace `[token]` with the token provided in step 3.

  Example of a valid piece of `config.json` :
  ```json
    {
      ...
      "chunk_distribution_network": {
      "enabled": true,
        "uris": {
          "get": "http://0.0.0.0:1324/get",
          "set": "http://0.0.0.0:1323/process?token=ccc111ccc111ccc111ccc111"
        }
      }
      ...
    }
  ```

7. **Restart the NEAR Node**
   Restart the NEAR node to apply the changes.

### NEAR Core Version Requirement
It is mandatory that the version of NEAR Core is at least 1.40.0-rc.1 to ensure compatibility with the near-rpc-speedup project. Please update your NEAR Core version if necessary.
### Update

To update the services to the latest version, you can run the following command:
```bash
./update.sh
```
This will rebuild the Docker images and restart the services.