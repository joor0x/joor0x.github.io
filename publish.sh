#!/bin/bash

# Quick publish script for blog
# Usage: ./publish.sh "commit message"

set -e

if [ -z "$1" ]; then
    echo "Usage: ./publish.sh \"commit message\""
    exit 1
fi

git add -A
git commit -m "$1"
git push

echo "Published! GitHub Actions will deploy shortly."
