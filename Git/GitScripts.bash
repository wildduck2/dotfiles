#!/bin/bash


# This script is written by Ahmed Ayob " wild_duck " 
# This script aimmed to make you 

echo 'Welcome to wild_duck Scripts'
echo '           _  _      _              _               _    
          (_)| |    | |            | |             | |   
__      __ _ | |  __| |          __| | _   _   ___ | | __
\ \ /\ / /| || | / _` |         / _` || | | | / __|| |/ /
 \ V  V / | || || (_| |        | (_| || |_| || (__ |   < 
  \_/\_/  |_||_| \__,_|         \__,_| \__,_| \___||_|\_\
                        ______                           
                       |______|                          
'
echo "This script is written by Ahmed Ayob \" wild_duck \" "

# Prompt the user for the full path of the repository on the same line
read -r -p "Navigate to the repo directory: " repo_path

# Check if the path was provided
if [ -z "$repo_path" ]; then
    echo "No path was provided. Exiting."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$repo_path" ]; then
    echo "The directory '$repo_path' does not exist."
    exit 1
fi

# Navigate to the directory
cd "$repo_path" || exit


#!/bin/bash

# Function to check if the remote 'origin' exists and add it if not
check_remote_origin_exists_and_add() {
    local remote_list=$(git remote -v)
    if echo "$remote_list" | grep -q "origin"; then
        echo "Remote 'origin' exists."
    else
        read -r -p "Remote 'origin' does not exist. Please enter the URL for the new remote 'origin':" remote_url
        git remote add origin "$remote_url"
        echo "Remote 'origin' added successfully."
    fi
}

# Function to initialize a new Git repository
init_git_repo() {
    git init || handle_dubious_ownership_error
}

# Function to handle permission denied errors
handle_permission_denied() {
    echo "Permission denied. Please enter your sudo password."
    sudo git init || handle_dubious_ownership_error
}

# Function to handle dubious ownership error
handle_dubious_ownership_error() {
    local repo_path="$PWD"
    echo "Dubious ownership detected in repository at '$repo_path'."
    echo "Adding an exception for this directory."
    git config --global --add safe.directory "$repo_path"
}

# Function to check if global Git config has user name and email
check_global_git_config() {
    local user_name=$(git config --global user.name)
    local user_email=$(git config --global user.email)

    if [ -z "$user_name" ] || [ -z "$user_email" ]; then
        return 1
    else
        return 0
    fi
}

# Function to prompt user to enter global Git config details
prompt_user_for_git_config() {
    echo "It seems your global Git configuration is missing a user name or email."
    read -r -p "Please enter your name: " user_name
    read -r -p "Please enter your email: " user_email

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"

    echo "Global Git configuration updated successfully."
}

# Function to create a branch if it doesn't exist
create_branch_if_not_exists() {
    local branch_name="$1"

    # Check if the branch exists locally
    if ! git show-ref --verify --quiet refs/heads/"$branch_name"; then
        echo "Creating branch '$branch_name'."
        git checkout -b "$branch_name"
    fi
}

# Function to push code to a specific branch
push_to_branch() {
    local branch_name="$1"

    echo "Pushing to branch '$branch_name'."
    # Attempt to push the branch and capture the output
    local push_output
    push_output=$(git push --set-upstream origin "$branch_name" 2>&1)

    # Check if the push was successful
    if [ $? -eq 0 ]; then
        echo "Push successful."
    else
        # Check if the error indicates no tracking information
        if echo "$push_output" | grep -q "There is no tracking information for the current branch"; then
            echo "Setting up tracking information for branch '$branch_name'."
            git branch --set-upstream-to=origin/"$branch_name" "$branch_name"
            echo "Now retrying the push..."
            # Retry the push after setting up tracking information
            push_output=$(git push --set-upstream origin "$branch_name" 2>&1)
            # Check if the second push attempt was successful
            if [ $? -eq 0 ]; then
                echo "Push successful after setting up tracking information."
            else
                echo "Error: Failed to push to branch '$branch_name'."
                echo "Please check your network connection and permissions."
                # Echo the error message
                echo "Error details: $push_output"
            fi
        else
            echo "Error: Failed to push to branch '$branch_name'."
            echo "Please check your network connection and permissions."
            # Echo the error message
            echo "Error details: $push_output"
        fi
    fi
}


# Main script starts here

# Check if the current directory is a Git repository
if [ ! -d ".git" ]; then
    echo "The directory '$PWD' is not a Git repository."

    # Prompt the user to create a new Git repository
    read -r -p "Do you want to create a new Git repository? [y/N] " response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo 'Attempting to create a new Git repository.'
        # Try to initialize a new Git repository
        init_git_repo || handle_permission_denied
    else
        echo "Exiting..., Thanks for using wild_duck scripts"
        exit 1
    fi
else
    echo "The directory '$PWD' is already a Git repository."
fi

# Check if the remote 'origin' exists and add it if not
check_remote_origin_exists_and_add

# Check if global Git config has user name and email
if ! check_global_git_config; then
    prompt_user_for_git_config
fi

# Now Ask them to enter the files you want to add
read -r -p "Enter the files you want to add: " files

# Add the files
git add "$files"

# Commit the changes
read -r -p "Enter the commit title: " title
read -r -p "Enter the commit description: " description

git commit -m "$title" -m "$description"

# Prompt the user for the branch name
read -r -p "Please enter the name of the branch you want to push to: " branch_name

# Trim leading and trailing whitespace
branch_name=$(echo "$branch_name" | xargs)

# Check if the branch name is empty
if [ -z "$branch_name" ]; then
    echo "Error: Branch name cannot be empty."
    exit 1
fi

# Create the branch if it doesn't exist
create_branch_if_not_exists "$branch_name"

# Push to the specified branch
push_to_branch "$branch_name"

