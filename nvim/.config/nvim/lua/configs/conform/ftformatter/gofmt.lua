-- You need `goimports` to be installed.
-- ```sh
-- go install golang.org/x/tools/cmd/goimports@latest
-- ```
-- OR=>> install it using mason
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://pkg.go.dev/cmd/gofmt',
    description = 'Formats go programs.',
  },
  command = 'goimports', -- Use goimports to format and manage imports
  args = {},
  stdin = true,
}
