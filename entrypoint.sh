#!/bin/bash

set -e

# Ensure required environment variables are set
if [ -z "$GIT_REPO_URL" ]; then
    echo "Error: GIT_REPO_URL environment variable is not set."
    exit 1
fi

# Step 1: Run apt-mirror to download repositories
echo "Starting apt-mirror to download repositories..."
apt-mirror || { echo "apt-mirror failed! Check the mirror.list file."; exit 1; }

# Step 2: Navigate to the mirror directory
MIRROR_DIR="/var/spool/apt-mirror/mirror"
if [ ! -d "$MIRROR_DIR" ]; then
    echo "Error: Mirror directory $MIRROR_DIR does not exist."
    exit 1
fi
cd "$MIRROR_DIR"

# Step 3: Initialize a Git repository (if not already initialized)
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git remote add origin "$GIT_REPO_URL"
fi

# Step 4: Configure Git LFS and track large files
echo "Configuring Git LFS..."
git lfs install
git lfs track "*"
git add .gitattributes

# Step 5: Add all files to Git
echo "Adding all files to Git..."
git add .

# Step 6: Commit the files
echo "Committing changes..."
COMMIT_MSG="Mirror update: $(date)"
git commit -m "$COMMIT_MSG" || echo "Nothing to commit."

# Step 7: Push to the remote repository
echo "Pushing to the remote Git repository..."
git push -u origin master || echo "Push failed! Check your Git repository configuration."

echo "Repository mirroring and upload completed successfully."
