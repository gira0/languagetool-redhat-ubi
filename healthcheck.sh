#!/bin/bash
#--interval=2m --start-period=5m --timeout=5s CMD curl -f http://localhost:8080/v2/languages || exit 1

# Run the podman container
container_id=$(podman run -d --rm -p 8080:8080 "$1")

# Wait for the container to start
sleep 5

# Test the container via a curl API call
status_code=$(curl -o response_body.json -w "%{http_code}" http://localhost:8080/v2/languages)

echo "Status code: $status_code"

if [ "$status_code" -ne 200 ]; then
  echo "Failed to get a 200 status code"
  exit 1
fi

echo "Response body:"
cat response_body.json

echo "Language count:"
COUNT=$(jq '. | length' response_body.json)

if [ "$COUNT" -lt 50 ]; then
  echo "Language Count too low to be valid"
  exit 1
fi

# Stop the container
podman stop "$container_id"
