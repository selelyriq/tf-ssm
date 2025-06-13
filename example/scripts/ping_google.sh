#!/bin/bash

# Example script: Ping Google DNS to test connectivity
echo "Testing network connectivity..."
ping -c 4 8.8.8.8 > /tmp/ping_results.txt
cat /tmp/ping_results.txt

if [ $? -eq 0 ]; then
    echo "Network connectivity test PASSED"
else
    echo "Network connectivity test FAILED"
fi 