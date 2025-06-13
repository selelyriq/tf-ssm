#!/bin/bash

# Example script: Hello World with system info
echo "Hello, World! This is a custom script running via SSM."
echo "Current date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"

# Save output to file
echo "Script executed successfully at $(date)" > /tmp/hello_world_output.txt
cat /tmp/hello_world_output.txt 