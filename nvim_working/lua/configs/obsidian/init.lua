local obsidian = require("obsidian")


local config = {
    -- a list of workspace names, paths, and configuration overrides.
    -- if you use the obsidian app, the 'path' of a workspace should generally be
    -- your vault root (where the `.obsidian` folder is located).
    -- when obsidian.nvim is loaded by your plugin manager, it will automatically set
    -- the workspace to the first workspace in the list whose `path` is a parent of the
    -- current markdown file being edited.
    workspaces = {
        {
            name = "personal",
            path = "/home/wildduck/wildduck/@duck-obsidian/wildduck/",
        },
        -- {
        --     name = "personal",
        --     path = "~/vaults/personal",
        -- },
        -- {
        --     name = "work",
        --     path = "~/vaults/work",
        --     -- optional, override certain settings.
        --     overrides = {
        --         notes_subdir = "notes",
        --     },
        -- },
    },

    -- alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
    -- 'workspaces'. for example:
    dir = "/home/wildduck/wildduck/@duck-ui/",

    -- optional, if you keep notes in a specific subdirectory of your vault.
    -- notes_subdir = "notes",

    -- optional, set the log level for obsidian.nvim. this is an integer corresponding to one of the log
    -- levels defined by "vim.log.levels.*".
    log_level = vim.log.levels.info,

    daily_notes = {
        -- optional, if you keep daily notes in a separate directory.
        folder = "notes/dailies",
        -- optional, if you want to change the date format for the id of daily notes.
        date_format = "%y-%m-%d",
        -- optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%b %-d, %y",
        -- optional, default tags to add to each new daily note created.
        default_tags = { "daily-notes" },
        -- optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = nil
    },

    -- optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
        -- set to false to disable completion.
        nvim_cmp = true,
        -- trigger completion at 2 chars.
        min_chars = 2,
    },

    -- optional, configure key mappings. these are the defaults. if you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    mappings = {
        -- overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
            action = function()
                return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
        },
        -- toggle check-boxes.
        ["<leader>ch"] = {
            action = function()
                return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true },
        },
        -- smart action depending on context, either follow link or toggle checkbox.
        ["<cr>"] = {
            action = function()
                return require("obsidian").util.smart_action()
            end,
            opts = { buffer = true, expr = true },
        }
    },

    -- where to put new notes. valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = "notes_subdir",

    -- optional, customize how note ids are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
        -- create note ids in a zettelkasten format with a timestamp and a suffix.
        -- in this case a note with the title 'my new note' will be given an id that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
            -- if title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^a-za-z0-9-]", ""):lower()
        else
            -- if title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
                suffix = suffix .. string.char(math.random(65, 90))
            end
        end
        return tostring(os.time()) .. "-" .. suffix
    end,

    -- optional, customize how note file names are generated given the id, target directory, and title.
    ---@param spec { id: string, dir: obsidian.path, title: string|? }
    ---@return string|obsidian.path the full path to the new note.
    note_path_func = function(spec)
        -- this is equivalent to the default behavior.
        local path = spec.dir / tostring(spec.id)
        return path:with_suffix(".md")
    end,

    -- optional, customize how wiki links are formatted. you can set this to one of:
    --  * "use_alias_only", e.g. '[[foo bar]]'
    --  * "prepend_note_id", e.g. '[[foo-bar|foo bar]]'
    --  * "prepend_note_path", e.g. '[[foo-bar.md|foo bar]]'
    --  * "use_path_only", e.g. '[[foo-bar.md]]'
    -- or you can set it to a function that takes a table of options and returns a string, like this:
    wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
    end,

    -- optional, customize how markdown links are formatted.
    markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
    end,

    -- either 'wiki' or 'markdown'.
    preferred_link_style = "wiki",

    -- optional, boolean or a function that takes a filename and returns a boolean.
    -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
    disable_frontmatter = false,

    -- optional, alternatively you can customize the frontmatter data.
    ---@return table
    note_frontmatter_func = function(note)
        -- add the title of the note as an alias.
        if note.title then
            note:add_alias(note.title)
        end

        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- so here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
                out[k] = v
            end
        end

        return out
    end,

    -- optional, for templates (see below).
    templates = {
        folder = "templates",
        date_format = "%y-%m-%d",
        time_format = "%h:%m",
        -- a map for custom variables, the key should be the variable and the value a function
        substitutions = {},
    },

    -- optional, by default when you use `:obsidianfollowlink` on a link to an external
    -- url it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
        -- open the url in the default web browser.
        vim.fn.jobstart({ "open", url }) -- mac os
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- windows
        -- vim.ui.open(url) -- need neovim 0.10.0+
    end,

    -- optional, by default when you use `:obsidianfollowlink` on a link to an image
    -- file it will be ignored but you can customize this behavior here.
    ---@param img string
    follow_img_func = function(img)
        vim.fn.jobstart { "qlmanage", "-p", img } -- mac os quick look preview
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- windows
    end,

    -- optional, set to true if you use the obsidian advanced uri plugin.
    -- https://github.com/vinzent03/obsidian-advanced-uri
    use_advanced_uri = false,

    -- optional, set to true to force ':obsidianopen' to bring the app to the foreground.
    open_app_foreground = false,

    picker = {
        -- set your preferred picker. can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
        name = "telescope.nvim",
        -- optional, configure key mappings for the picker. these are the defaults.
        -- not all pickers support all mappings.
        note_mappings = {
            -- create a new note from your query.
            new = "<c-x>",
            -- insert a link to the selected note.
            insert_link = "<c-l>",
        },
        tag_mappings = {
            -- add tag(s) to current note.
            tag_note = "<c-x>",
            -- insert a tag at the current location.
            insert_tag = "<c-l>",
        },
    },

    -- optional, sort search results by "path", "modified", "accessed", or "created".
    -- the recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
    -- that `:obsidianquickswitch` will show the notes sorted by latest modified time
    sort_by = "modified",
    sort_reversed = true,

    -- set the maximum number of lines to read from notes on disk when performing certain searches.
    search_max_lines = 1000,

    -- optional, determines how certain commands open notes. the valid options are:
    -- 1. "current" (the default) - to always open in the current window
    -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
    -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
    open_notes_in = "current",

    -- optional, define your own callbacks to further customize behavior.
    callbacks = {
        -- runs at the end of `require("obsidian").setup()`.
        ---@param client obsidian.client
        post_setup = function(client) end,

        -- runs anytime you enter the buffer for a note.
        ---@param client obsidian.client
        ---@param note obsidian.note
        enter_note = function(client, note) end,

        -- runs anytime you leave the buffer for a note.
        ---@param client obsidian.client
        ---@param note obsidian.note
        leave_note = function(client, note) end,

        -- runs right before writing the buffer for a note.
        ---@param client obsidian.client
        ---@param note obsidian.note
        pre_write_note = function(client, note) end,

        -- runs anytime the workspace is set/changed.
        ---@param client obsidian.client
        ---@param workspace obsidian.workspace
        post_set_workspace = function(client, workspace) end,
    },

    -- optional, configure additional syntax highlighting / extmarks.
    -- this requires you have `conceallevel` set to 1 or 2. see `:help conceallevel` for more details.
    ui = {
        enable = true,          -- set to false to disable all additional syntax features
        update_debounce = 200,  -- update delay after a text change (in milliseconds)
        max_file_length = 5000, -- disable ui features for files with more than this many lines
        -- define how various check-boxes are displayed
        checkboxes = {
            -- note: the 'char' value has to be a single character, and the highlight groups are defined below.
            [" "] = { char = "󰄱", hl_group = "obsidiantodo" },
            ["x"] = { char = "", hl_group = "obsidiandone" },
            [">"] = { char = "", hl_group = "obsidianrightarrow" },
            ["~"] = { char = "󰰱", hl_group = "obsidiantilde" },
            ["!"] = { char = "", hl_group = "obsidianimportant" },
            -- replace the above with this if you don't have a patched font:
            -- [" "] = { char = "☐", hl_group = "obsidiantodo" },
            -- ["x"] = { char = "✔", hl_group = "obsidiandone" },

            -- you can also add more custom ones...
        },
        -- use bullet marks for non-checkbox lists.
        bullets = { char = "•", hl_group = "obsidianbullet" },
        external_link_icon = { char = "", hl_group = "obsidianextlinkicon" },
        -- replace the above with this if you don't have a patched font:
        -- external_link_icon = { char = "", hl_group = "obsidianextlinkicon" },
        reference_text = { hl_group = "obsidianreftext" },
        highlight_text = { hl_group = "obsidianhighlighttext" },
        tags = { hl_group = "obsidiantag" },
        block_ids = { hl_group = "obsidianblockid" },
        hl_groups = {
            -- the options are passed directly to `vim.api.nvim_set_hl()`. see `:help nvim_set_hl`.
            obsidiantodo = { bold = true, fg = "#f78c6c" },
            obsidiandone = { bold = true, fg = "#89ddff" },
            obsidianrightarrow = { bold = true, fg = "#f78c6c" },
            obsidiantilde = { bold = true, fg = "#ff5370" },
            obsidianimportant = { bold = true, fg = "#d73128" },
            obsidianbullet = { bold = true, fg = "#89ddff" },
            obsidianreftext = { underline = true, fg = "#c792ea" },
            obsidianextlinkicon = { fg = "#c792ea" },
            obsidiantag = { italic = true, fg = "#89ddff" },
            obsidianblockid = { italic = true, fg = "#89ddff" },
            obsidianhighlighttext = { bg = "#75662e" },
        },
    },

    -- specify how to handle attachments.
    attachments = {
        -- the default folder to place images in via `:obsidianpasteimg`.
        -- if this is a relative path it will be interpreted as relative to the vault root.
        -- you can always override this per image by passing a full path to the command instead of just a filename.
        img_folder = "assets/imgs", -- this is the default

        -- optional, customize the default name or prefix when pasting images via `:obsidianpasteimg`.
        ---@return string
        img_name_func = function()
            -- prefix image names with timestamp.
            return string.format("%s-", os.time())
        end,

        -- a function that determines the text to insert in the note when pasting an image.
        -- it takes two arguments, the `obsidian.client` and an `obsidian.path` to the image file.
        -- this is the default implementation.
        ---@param client obsidian.client
        ---@param path obsidian.path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
            path = client:vault_relative_path(path) or path
            return string.format("![%s](%s)", path.name, path)
        end,
    },
}
obsidian.setup(config)
