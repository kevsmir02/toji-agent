#!/bin/bash
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  echo '{"continue":true}'
  exit 0
fi

if [ -f .agent/task.md ]; then
  UNCOMPLETED=$(grep -c '\[ \]' .agent/task.md)
  if [ "$UNCOMPLETED" -gt 0 ]; then
    echo '{"hookSpecificOutput": {"hookEventName": "Stop", "decision": "block", "reason": "There are uncompleted items in .agent/task.md. Please complete them or ask the user if they can be left uncompleted."}}'
    exit 0
  fi
fi

echo '{"continue":true}'
