#!/bin/bash

# Fetch top stories IDs from Hacker News
TOP_STORIES_URL="https://hacker-news.firebaseio.com/v0/topstories.json"
TOP_STORY_IDS=$(curl -s "$TOP_STORIES_URL" | jq '.[]')

# Function to fetch and display a single story
fetch_story() {
    local STORY_ID=$1
    STORY_URL="https://hacker-news.firebaseio.com/v0/item/${STORY_ID}.json"
    STORY=$(curl -s "$STORY_URL")
    TITLE=$(echo "$STORY" | jq -r '.title')
    URL=$(echo "$STORY" | jq -r '.url')
    echo "Title: $TITLE"
    echo "URL: $URL"
    echo "-------------------------"
}

# Maximum number of concurrent jobs
MAX_JOBS=10
CURRENT_JOBS=0

# Loop through the top story IDs and fetch each story concurrently
for STORY_ID in $TOP_STORY_IDS; do
    fetch_story $STORY_ID &
    CURRENT_JOBS=$((CURRENT_JOBS + 1))
    
    # If the number of concurrent jobs reaches the limit, wait for them to complete
    if [ "$CURRENT_JOBS" -ge "$MAX_JOBS" ]; then
        wait
        CURRENT_JOBS=0
    fi
done

# Wait for any remaining background jobs to complete
wait
