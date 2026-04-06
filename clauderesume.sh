#!/bin/sh

: << EOF
Claude resume command to start claude code again using the most recent chat.

Note that claude code will only resume the conversation if you are in the correct project directory.
This will also move the terminal CWD to the appropriate value.
EOF

# script variables
CLAUDEPATH=""
CLAUDEHIST="$HOME/.claude/history.jsonl"

# script version
VERSION="0.1.0"

# ANSI colours
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# print functions
print_success() { printf "${GREEN}Success: %s${NC}\n" "$1"; }
print_error()   { printf "${RED}Error: %s${NC}\n" "$1"; }

# help message
show_help() {
    cat << EOF
clauderesume.sh - restarts the most recent claude code session

USAGE: clauderesume.sh <OPTIONS> [PATH]

OPTIONS:
    -h|--help       Show this help message
    -v|--version    See script version
    -f|--file       Claude history file (Default: ~/.claude/history.jsonl)

ARGUMENTS:
    PATH            The directory in which to find previous conversations

If no PATH is provided, this script will search for the most recent claude session
if any project directory and resume there.
EOF
}

# parsing arguments
while [ $# -gt 0 ]; do
    case "$1" in 
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$VERSION"
            exit 0
            ;;
        -f|--file)
            CLAUDEHIST="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option $1 provided"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# parsing positional arguments
CLAUDEPATH="$1"

# expand to an absolute path if claudepath is set
if [ -n "$CLAUDEPATH" ]; then
    CLAUDEPATH="$(cd "$CLAUDEPATH" 2>/dev/null && pwd)" # I would describe this as hacky
    if [ -z "$CLAUDEPATH" ]; then # raise an error if this path doesn't exist 
        print_error "Path $1 does not exist"
        exit 1
    fi
fi

# check that the CLAUDEHIST file is present
if [ ! -f "$CLAUDEHIST" ]; then
    print_error "Claude history file $CLAUDEHIST not found"
    exit 1 
fi

# if CLAUDEPATH is empty, then this script will find the most recent claude session in any directory,
# move the CWD to the appropriate project dir and resume there
if [ -z "$CLAUDEPATH" ]; then
    # find the appropriate session ID from the claude history JSON file
    session_id=$(tail -n 1 "$CLAUDEHIST" | jq -r '.sessionId')

    # get the project directory
    project=$(tail -n 1 "$CLAUDEHIST" | jq -r '.project')

    print_success "Found sessionID $session_id in project directory $project as the most recent claude session"
    print_success "Moving to project directory $project ..."

    # changing CWD to the project directory
    cd "$project" || { print_error "Failed to cd to $project"; exit 1; }

    # resuming claude code using that session ID
    claude --resume "$session_id"
# if CLAUDEPATH contains data, it will search for the most recent claude session with that PATH as the 
# project directory
else
    # find the appropriate session ID
    session_id=$(cat "$CLAUDEHIST" | jq -r --arg path "$CLAUDEPATH" 'select(.project == $path) | .sessionId' | tail -n 1)

    # hits an error if no session_id is returned for the specified path
    if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
        print_error "No sessions found with project directory $CLAUDEPATH in history file $CLAUDEHIST"
        exit 1
    fi

    # changing CWD to the specified project directory
    cd "$CLAUDEPATH" || { print_error "Failed to cd to $CLAUDEPATH"; exit 1; }

    # if a session ID was found
    claude --resume "$session_id"
fi
