#!/bin/bash
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL_NAME" = "editFiles" ] || [ "$TOOL_NAME" = "createFile" ] || [ "$TOOL_NAME" = "edit/editFiles" ] || [ "$TOOL_NAME" = "edit/createFile" ]; then
  FILES=$(echo "$INPUT" | jq -r '.tool_input.files[]? // .tool_input.path // empty')

  for FILE in $FILES; do
    if [ -f "$FILE" ]; then
      # Run prettier if applicable
      if [[ "$FILE" =~ \.(js|ts|jsx|tsx|json|md|css|html)$ ]]; then
        npx prettier --write "$FILE" 2>/dev/null
      fi
    fi
  done
fi

echo '{"continue":true}'
