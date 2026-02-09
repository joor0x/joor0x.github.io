#!/bin/bash

# Quick publish script for blog
# Usage: ./publish.sh "commit message"

set -e

if [ -z "$1" ]; then
    echo "Usage: ./publish.sh \"commit message\""
    exit 1
fi

ALLOW_EMPTY=0
if [ "$1" = "--allow-empty" ]; then
    ALLOW_EMPTY=1
    shift
fi

if [ -z "$1" ]; then
    echo "Usage: ./publish.sh [--allow-empty] \"commit message\""
    exit 1
fi

git add -A

if git diff --cached --quiet; then
    if [ "$ALLOW_EMPTY" -eq 1 ]; then
        git commit --allow-empty -m "$1"
        git push
        echo "Published (empty commit)! GitHub Actions will deploy shortly."
        exit 0
    fi

    echo "Nothing to commit."
    echo "- If you want to force a rebuild/deploy, run: ./publish.sh --allow-empty \"$1\""
    echo "- Or trigger the workflow manually from GitHub Actions (workflow_dispatch)."
    exit 0
fi

git commit -m "$1"
git push

echo "Published! GitHub Actions will deploy shortly."
