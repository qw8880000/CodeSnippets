#!/bin/bash

MATCH_STRING="test"

# Get process ID
process_id=$(pgrep -f "$MATCH_STRING")

# Get thread count
thread_count=$(pstree -p $process_id | wc -l)

echo $thread_count

