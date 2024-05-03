#!/bin/bash
#--interval=2m --start-period=5m --timeout=5s CMD curl -f http://localhost:8080/v2/languages || exit 1

# Run the podman container
container_id=$(podman run -d --rm -p 8080:8080 $1)

# Wait for the container to start
sleep 5

# Test the container via a curl API call
curl -f http://localhost:8080/v2/languages || exit 1

# Stop the container
podman stop $container_id
