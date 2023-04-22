#!/bin/bash

CURR_DIR=$(pwd)

# Parse the -m option and assign it to a variable
while getopts ":m:" opt; do
  case $opt in
    m)
      model="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Use sed to change the <model> tag in a file
sed -i .sh "s|<model>|${model}|g" suggestion.sh
sed -i .sh "s|<current>|$CURR_DIR|g" suggestion.sh


# Set the git pre-hook directory globally in the current directory
git config --global core.hooksPath "$CURR_DIR"