return {
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      -- auto-format with rustfmt on save
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    version = false, -- update to latest; run :Lazy update to pull newest version
    lazy = false, -- plugin is already lazy by design (loads on ft=rust)
    init = function()
      -- configure before the plugin loads on first rust file
      require('plugins.lang.rust.config').setup()
    end,
  },
}
