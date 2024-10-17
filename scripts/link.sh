#!/bin/bash

# Check if QHOME is set
if [ -z "$QHOME" ]; then
  echo "Error: QHOME is not set. Please set QHOME before running the script."
  exit 1
fi

# Check if QHOME directory exists
if [ ! -d "$QHOME" ]; then
  echo "Error: QHOME directory does not exist: $QHOME"
  exit 1
fi

# Directories to link
dirs=("ml" "nlp" "automl")

# Check if each directory exists in the current working directory
for dir in "${dirs[@]}"; do
  if [ ! -d "$PWD/$dir" ]; then
    echo "Error: Directory $PWD/$dir does not exist. Please ensure it exists before running the script."
    exit 1
  fi
done

# Create symbolic links
for dir in "${dirs[@]}"; do
  ln -s "$PWD/$dir" "$QHOME/$dir"
  echo "Linked $PWD/$dir to $QHOME/$dir"
done

