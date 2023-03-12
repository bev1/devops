#!/bin/bash

DB_FILE="./../data/users.db"
BACKUP_DIR="./backups"

# Check if the users.db file exists
if [[ ! -f $DB_FILE ]]; then
    read -p "The users.db file does not exist. Do you want to create one? [y/n]: " choice
    if [[ $choice == "y" ]]; then
        touch $DB_FILE
        echo "New users.db file created."
    else
        echo "Exiting the script."
        exit 0
    fi
fi

# Function to check if the entered string contains only latin letters
function validate_input() {
    input=$1
    if [[ ! $input =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid input. Please enter latin letters only."
        exit 1
    fi
}

# Function to get the last backup file
function get_last_backup() {
    last_backup=$(ls -t $BACKUP_DIR/*.backup 2>/dev/null | head -1)
    if [[ -z $last_backup ]]; then
        echo "No backup file found."
        exit 1
    fi
}

# Function to print usage instructions
function print_usage() {
    echo "Usage: db.sh <command> [<args>]"
    echo "Commands:"
    echo "  add     : Add a new line to the users.db"
    echo "  backup  : Create a backup file"
    echo "  restore : Restore users.db from the last backup"
    echo "  find    : Find a user by username"
    echo "  list    : List all users"
    echo "  help    : Display this help message"
}

# Check if the user has provided any arguments
if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
fi

# Parse the command line arguments
case $1 in
    "add")
        read -p "Enter the username: " username
        validate_input $username
        read -p "Enter the role: " role
        validate_input $role
        echo "$username,$role" >> $DB_FILE
        echo "User $username with role $role added to users.db"
        ;;
    "backup")
        timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        backup_file="$BACKUP_DIR/$timestamp-users.db.backup"
        cp $DB_FILE $backup_file
        echo "New backup created: $backup_file"
        ;;
    "restore")
        get_last_backup
        cp $last_backup $DB_FILE
        echo "users.db restored from $last_backup"
        ;;
    "find")
        read -p "Enter the username to search: " search_query
        grep_result=$(grep -i "^$search_query" $DB_FILE)
        if [[ -z $grep_result ]]; then
            echo "User not found."
        else
            echo "$grep_result"
        fi
        ;;
    "list")
        if [[ $2 == "--inverse" ]]; then
            tac $DB_FILE | nl -n ln -s ', '
        else
            nl -n ln -s ', ' $DB_FILE
        fi
        ;;
    "help")
        print_usage
        ;;
    *)
        echo "Invalid command. Use 'db.sh help' to see available commands."
        ;;
esac
