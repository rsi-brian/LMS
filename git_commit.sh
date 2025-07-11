#!/bin/bash
set -e

# --- Configuration ---
DEFAULT_BRANCH="${DEFAULT_BRANCH:-}"

# --- Script Start ---
echo "-------------------------------------"
echo " Git Automated Add & Commit Script "
echo "-------------------------------------"

# 1. Check if we are inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository. Please navigate to your project directory."
    exit 1
fi

# 2. Display current Git status
echo "Current Git status:"
git status --short
echo ""

# 3. Add all current changes
echo "Staging all changes with 'git add -A'..."
git add -A || { echo "Error: Failed to stage changes. Aborting."; exit 1; }
echo "All changes staged successfully."
echo ""

# 4. Check if there are changes to commit
if git diff --cached --exit-code && git diff --exit-code; then
    echo "No changes to commit."
    exit 0
fi

# 5. Prompt for a commit message (ignore whitespace)
commit_message=""
while [[ -z "${commit_message// /}" ]]; do
    read -p "Please enter your commit message: " commit_message
    if [[ -z "${commit_message// /}" ]]; then
        echo "Commit message cannot be empty. Please try again."
    fi
done
echo ""

# 6. Perform the commit
echo "Committing changes with message: \"$commit_message\""
git commit -m "$commit_message" || { echo "Error: Failed to commit changes. Aborting."; exit 1; }
git --no-pager log -1 --oneline
echo "Changes committed successfully!"
echo ""

# 7. Optional: Push changes to remote
read -p "Do you want to push these changes to the remote repository? (y/N): " push_choice
push_choice=${push_choice:-n}

if [[ "$push_choice" =~ ^[Yy]$ ]]; then
    if [ -z "$DEFAULT_BRANCH" ]; then
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ $? -ne 0 ]; then
            echo "Error: Could not determine current branch for push. Please specify DEFAULT_BRANCH in script or push manually."
            exit 1
        fi
        if [ "$current_branch" = "HEAD" ]; then
            echo "You are in a detached HEAD state. Please checkout a branch before pushing."
            exit 1
        fi
        push_branch="$current_branch"
    else
        push_branch="$DEFAULT_BRANCH"
    fi

    echo "Pushing changes to origin/$push_branch..."
    git push origin "$push_branch" || { echo "Error: Failed to push changes. You may need to resolve issues manually (e.g., pull first)."; exit 1; }
    echo "Changes pushed successfully!"
else
    echo "Push skipped. Remember to push your changes later."
fi

echo "-------------------------------------"
echo " Script Finished. "
echo "-------------------------------------"