-- You need `goimports` to be installed.
-- ```sh
-- go install golang.org/x/tools/cmd/goimports@latest
-- ```
-- OR=>> install it using mason
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://pkg.go.dev/cmd/goimports',
    description = 'Formats Go code and handles imports.',
  },
  command = 'goimports', -- Use goimports for both formatting and managing imports
  args = {}, -- No additional arguments needed for default behavior
  stdin = true, -- Read from stdin for conform integration
}
