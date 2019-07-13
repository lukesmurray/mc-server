#!/bin/bash
# Start up script run once when the server boots. 
# Starts the server and cron jobs.

set -e

cd /app && \

echo "starting the cron jobs" && \
sudo crontab crontab && \

echo "starting the server" && \
docker-compose up -d
