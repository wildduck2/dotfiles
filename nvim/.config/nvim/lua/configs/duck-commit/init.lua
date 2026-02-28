--[[
  @author: wildduck2 (https://github.com/wildduck2)

  AI Commit Message Generator for Neovim & Fugitive

  This code creates a self-contained function in your Neovim config
  that generates a commit message using the Google AI API.

  Dependencies:
    - Neovim 0.7+
    - Fugitive.vim plugin
    - `curl` command-line tool
    - A GEMINI_API_KEY environment variable set in your shell
]]

-- Create a dedicated table to hold our functions
local M = {}

---
-- The main function to generate and insert the commit message.
--
function M.generate_commit_message()
  -- --- Configuration ---
  local AI_model = 'gemini-2.5-flash' -- stable model as of late 2025

  -- Get API key
  -- local AI_api_key = vim.fn.getenv 'GEMINI_API_KEY'
  local AI_api_key = 'AIzaSyC949_jusyYz_dU7moU9ARO3lBMgm0Ng08' --vim.fn.getenv 'GEMINI_API_KEY'
  if AI_api_key == nil or AI_api_key == '' then
    vim.notify('Error: GEMINI_API_KEY environment variable is not set.', vim.log.levels.ERROR)
    return
  end

  local api_url = 'https://generativelanguage.googleapis.com/v1beta/models/'
    .. AI_model
    .. ':generateContent?key='
    .. AI_api_key

  -- 1. Pre-flight Check: staged files
  if vim.fn.system 'git diff --quiet --cached' == 0 then
    vim.notify('No changes staged for commit.', vim.log.levels.WARN)
    return
  end

  vim.notify('Getting staged changes...', vim.log.levels.INFO)
  local staged_diff = vim.fn.system 'git diff --cached'

  -- Create the prompt
  local prompt = [[
Based on the following git diff, generate a detailed commit message.

The format MUST strictly follow the Conventional Commits specification, with a detailed body.
Here is the required format:
<type>(<scope>): <subject>

- Detailed point 1 explaining a key change.
- Detailed point 2 explaining another key change.
- ... and so on for all significant changes.

RULES:
- The <type> must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore.
- The <scope> should be a short word describing the area of the codebase affected. If it affects many areas, use 'all'.
- The <subject> is a short, imperative summary of the changes.
- The body MUST be a bulleted list explaining the "what" and "why" of the changes.
- Do NOT include any introductory phrases like 'Here is the commit message' or markdown formatting like backticks in the final output.

Here is the git diff to analyze:
---
]] .. staged_diff .. [[
---
]]

  -- Escape prompt for JSON
  local escaped_prompt = vim.fn.escape(prompt, '"\\')
  local json_payload = string.format('{"contents":[{"parts":[{"text": "%s"}]}]}', escaped_prompt)

  vim.notify('Asking AI to write the commit message...', vim.log.levels.INFO)

  -- Prepare the curl command (read JSON from stdin instead of passing it as an argument)
  local curl_cmd = {
    'curl',
    '-s',
    '-H',
    'Content-Type: application/json',
    '--data-binary',
    '@-',
    api_url,
  }

  -- Start curl job with stdin pipe
  local job_id = vim.fn.jobstart(curl_cmd, {
    stdin = 'pipe',
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.schedule(function()
          vim.notify('Curl command failed with exit code: ' .. exit_code, vim.log.levels.ERROR)
        end)
      end
    end,
    on_stdout = function(_, data)
      if data then
        local full_response = table.concat(data, '')
        local ok, response_data = pcall(vim.json.decode, full_response)

        if not ok or not response_data or not response_data.candidates then
          vim.schedule(function()
            vim.notify(
              'Failed to parse JSON response from API. Full response: ' .. full_response,
              vim.log.levels.ERROR
            )
          end)
          return
        end

        local text = response_data.candidates[1].content.parts[1].text
        if not text then
          vim.schedule(function()
            -- vim.notify('No text found in API response.', vim.log.levels.ERROR)
          end)
          return
        end

        vim.schedule(function()
          local lines = vim.split(text, '\n')
          table.insert(lines, '') -- add a blank line at the end
          vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
          vim.notify('🌳 Commit message generated and inserted!', vim.log.levels.INFO)
        end)
      end
    end,
  })

  -- Send payload via stdin
  vim.fn.chansend(job_id, json_payload)
  vim.fn.chanclose(job_id, 'stdin')
end

-- --- Keymap Setup ---
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gitcommit',
  callback = function()
    vim.keymap.set({ 'n', 'i' }, '<leader>gc', M.generate_commit_message, {
      noremap = true,
      silent = true,
      buffer = true, -- Local to commit buffer
      desc = '🌳 Generate commit message with AI',
    })
  end,
})

return M
