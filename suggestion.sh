#!/bin/bash

# Initialize variables
FILE_PATH=/tmp/tmp.txt
OS_MODEL='macOS'

exec &> /tmp/output.log

# Check OS type

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_MODEL='macOS/gpt4all-lora-quantized-OSX-m1'
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS_MODEL='linux/gpt4all-lora-quantized-linux-x86'
else
  echo "Unsupported operating system."
  exit 1
fi

CURR_DIR=$(pwd)

# Get the name of the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
# Get the name of the previous branch
previous_branch=$(git rev-parse --abbrev-ref @{-5})
diff=$(git diff "$previous_branch" "$current_branch")

# Find added and removed code chunks
added=$(echo "$diff" | grep -E '^\+' | sed 's/^\++ //')
removed=$(echo "$diff" | grep -E '^\-' | sed 's/^\-- //')

# Remove filename from the diff
added=$(echo "$added" | sed 's/^--- a\/.*$//')
removed=$(echo "$removed" | sed 's/^+++ b\/.*$//')

# Remove leading and trailing whitespace
added=$(echo "$added" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
removed=$(echo "$removed" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# shellcheck disable=SC2261
/Users/loghi/Documents/git-hooks/models/$OS_MODEL -m /Users/loghi/Documents/git-hooks/models/gpt4all.bin -p "Generate a short summary of this code change below. $added $removed" > $FILE_PATH

# Check if the file exists
if [ -f "$FILE_PATH" ]; then

  # Read the contents of the file and store it in a variable
  FILE_CONTENT=$(cat "$FILE_PATH")

  # Echo the contents of the file
  echo "$FILE_CONTENT"
else
  # If the file does not exist, display an error message
  echo "Error: File not found"
  exit 0
fi


# Set the file name based on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  # For macOS
  osascript -e 'display alert "Suggestions for PR" message "'"$FILE_CONTENT"'"'

  # Display alerts
  if [ ! -z "$added" ]; then
    osascript -e 'display notification "'"$added"'" with title "Added code chunk"'
    sleep 5
  fi

  if [ ! -z "$removed" ]; then
    osascript -e 'display notification "'"$removed"'" with title "Removed code chunk"'
    sleep 5
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # For Linux
  notify-send 'Suggestions for PR' "'"$FILE_CONTENT"'"

    # Display alerts
    if [ ! -z "$added" ]; then
      notify-send "Added code chunk" "'"$added"'"
      sleep 5
    fi

    if [ ! -z "$removed" ]; then
      notify-send "Added code chunk" "'"$removed"'"
      sleep 5
    fi
else
  echo "Unsupported operating system."
  exit 1
fi


