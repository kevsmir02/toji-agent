#!/bin/bash
# Inject project governance context at session start
PROJECT_INFO=$(cat package.json 2>/dev/null | jq -r '.name + " v" + .version' || echo "toji-agent")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
HAS_TASK=$([ -f .agent/task.md ] && echo "true" || echo "false")
LESSONS=$(head -50 .github/lessons-learned.md 2>/dev/null || echo "No lessons file")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Project: $PROJECT_INFO | Branch: $BRANCH | Active task.md: $HAS_TASK\n\nRecent Lessons:\n$LESSONS"
  }
}
EOF
