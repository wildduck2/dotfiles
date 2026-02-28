local dbee = require 'dbee'

--[[optional config]]
dbee.setup({
    connection = {
        sslmode = 'disable', -- Or 'require', 'prefer', etc., based on your setup
    },
})
