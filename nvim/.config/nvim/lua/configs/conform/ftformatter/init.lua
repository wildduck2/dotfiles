local M = {
  lua = require 'configs.conform.ftformatter.lua',
  gofumpt = require 'configs.conform.ftformatter.gofmt',
  goimports = require 'configs.conform.ftformatter.goimports',
  rustfmt = require 'configs.conform.ftformatter.rustfmt',
  clang_format = require 'configs.conform.ftformatter.clang',
  biome = require 'configs.conform.ftformatter.biome',
}

return M
