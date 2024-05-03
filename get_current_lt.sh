#!/bin/bash

# This script retrieves the current version of LanguageTool from the Containerfile and sets the variable for the workflow.
CONTAINER_LT=$(sed -E 's|ARG LT_VER=(.*)$|\1|g' Containerfile)
echo "LT_VERSION=$CONTAINER_LT" >> "$GITHUB_OUTPUT"
