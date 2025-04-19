local dbee = require 'dbee'

--[[optional config]]
local config = {
  connection = {
    sslmode = 'disable', -- Or 'require', 'prefer', etc., based on your setup
  },
}

dbee.setup(config)
