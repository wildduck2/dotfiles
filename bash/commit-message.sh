#!/usr/bin/env bash
# powerful-free-ai-commit.sh — generate long, structured conventional commit messages
# Fully free, uses Hugging Face instruction-tuned Flan-T5 model

set -e

# -----------------------------
# 1. Check staged changes
# -----------------------------
DIFF=$(git diff --cached)
if [ -z "$DIFF" ]; then
  echo "❌ No staged changes. Run 'git add' first."
  exit 1
fi

# -----------------------------
# 2. Choose model
# -----------------------------
MODEL="google/flan-t5-large" # Instruction-tuned, better for long structured output
echo "🔹 Generating commit message using $MODEL..."

# -----------------------------
# 3. Build prompt for multi-line commit
# -----------------------------
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

# -----------------------------
# 4. Call Hugging Face free inference API
# -----------------------------
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{\"inputs\": \"$PROMPT\"}" \
  https://api-inference.huggingface.co/models/$MODEL)

# -----------------------------
# 5. Parse response
# -----------------------------
# Flan-T5 returns a JSON array
MSG=$(echo "$RESPONSE" | jq -r '
  if type=="array" then .[0].generated_text
  else .generated_text
  end
')

# -----------------------------
# 6. Fallback
# -----------------------------
if [ -z "$MSG" ] || [ "$MSG" == "null" ]; then
  MSG="chore: update code (automatic commit message)"
fi

# -----------------------------
# 7. Show suggestion & confirm
# -----------------------------
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

