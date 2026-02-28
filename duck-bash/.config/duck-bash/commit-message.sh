#!/usr/bin/env bash
# commit-message-hf.sh — generate structured conventional commit messages using Hugging Face free API

set -e

DIFF=$(git diff --cached)
if [ -z "$DIFF" ]; then
  echo "❌ No staged changes. Run 'git add' first."
  exit 1
fi

KEY_FILE="$HOME/.config/huggingface/api_key"
mkdir -p "$(dirname "$KEY_FILE")"

get_hf_key() {
  if [ -f "$KEY_FILE" ]; then
    cat "$KEY_FILE"
  else
    read -p "🔹 Enter your Hugging Face API key: " HF_KEY
    echo "$HF_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo "✅ Key saved to $KEY_FILE"
    echo "$HF_KEY"
  fi
}

HF_KEY=$(get_hf_key)

# Use a model that supports text generation over HF free API
MODEL="tiiuae/falcon-7b-instruct" # works with free API for text generation
echo "🔹 Generating commit message using $MODEL..."

PROMPT="You are an AI that writes conventional commit messages.
Given the following staged git diff, generate a long, detailed commit message
with a proper header (type(scope): summary) and multiple bullet points explaining the changes.

Format:
<type>(<scope>): <short summary>

- <bullet 1>
- <bullet 2>
- <bullet 3>
...

Diff:
$DIFF

Commit message:"

call_hf_api() {
  curl -s -X POST \
    -H "Authorization: Bearer $HF_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"inputs\": \"$PROMPT\"}" \
    "https://api-inference.huggingface.co/models/$MODEL"
}

while true; do
  RESPONSE=$(call_hf_api)

  # Debug output
  echo "📝 Raw response from Hugging Face:"
  echo "$RESPONSE"

  if echo "$RESPONSE" | grep -iq "error"; then
    echo "❌ Authentication failed or insufficient permissions."
    rm -f "$KEY_FILE"
    HF_KEY=$(get_hf_key)
  else
    break
  fi
done

# Falcon models return JSON with "generated_text"
MSG=$(echo "$RESPONSE" | jq -r '.generated_text // empty')

if [ -z "$MSG" ]; then
  MSG="chore: update code (automatic commit message)"
fi

echo ""
echo "💡 Suggested commit message:"
echo "------------------------------------"
echo "$MSG"
echo "------------------------------------"
echo ""

read -p "Use this commit message? (y/n) " yn
if [[ "$yn" =~ ^[Yy] ]]; then
  git commit -m "$MSG"
  echo "✅ Commit created."
else
  echo "❌ Commit aborted."
fi

