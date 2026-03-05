local M = {
  lua = require 'plugins.conform.formatters.lua',
  gofumpt = require 'plugins.conform.formatters.gofmt',
  goimports = require 'plugins.conform.formatters.goimports',
  rustfmt = require 'plugins.conform.formatters.rustfmt',
  clang_format = require 'plugins.conform.formatters.clang',
  biome = require 'plugins.conform.formatters.biome',
}

return M
