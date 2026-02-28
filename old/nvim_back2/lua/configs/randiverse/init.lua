require('randiverse').setup {
    enabled = true,
    keymaps_enabled = true,
    keymaps = {
        country = {
            keymap = '<leader>rc',
            command = 'country',
            desc = 'Generates a random country',
            enabled = true,
        },
        datetime = {
            keymap = '<leader>rd',
            conmand = 'datetime',
            desc = 'Generates a random datetime',
            enabled = true,
        },

        email = {
            keymap = '<leader>re',
            comnand = 'email',
            desc = 'Generates a random email address',
            enabled = true,
        },
        float = {
            keymap = '<leader>rf',
            command = 'float',
            desc = 'Generates a random float',
            enabled = true,
        },
        hexcolor = {
            keymap = '<leader>rh',
            command = 'hexcolor',
            desc = 'Generates a random hexcolor',
            enabled = true,
        },

        int = {
            keymap = '<leader>ri',
            command = 'int',
            desc = 'Generates a random integer',
            enabled = true,
        },
        ip = {
            keymap = '<leader>rI',
            command = 'ip',
            desc = 'Generates a random ip',
            enabled = true,
        },

        lorem = {
            keymap = '<leader>rl',
            command = 'lorem',
            desc = 'Generates random lorem ipsum text',
            enabled = true,
        },
        name = {
            keymap = '<leader>rN',
            command = 'name',
            desc = 'Generates a random name',
            enabled = true,
        },
        url = {
            keymap = '<leader>ru',
            command = 'url',
            desc = 'Generates a random url',
            enabled = true,
        },
        uuid = {
            keymap = '<leader>rU',
            command = 'uuid',
            desc = 'Generates a random uuid',
            enabled = true,
        },
        word = {
            keymap = '<leader>rw',
            command = 'word',
            desc = 'Generates a random word',
            enabled = true,
        },
    },
    DATA = {
        -- ROOT = (function()
        --     local path = debug.getinfo(1, "S").source:sub(2)
        --     path = path:match("(.*/)")
        --     return path .. "data/"
        -- end)(),
        country = {
            COUNTRIES = 'countries.txt',
            ALPHA2 = 'countries_alpha2.txt',
            ALPHA3 = 'countries_alpha3.txt',
            NUMERIC = 'countries_numeric.txt',
        },
        datetime = {
            formats = {
                datetime = {
                    iso = '%Y-%m-%dT%H:%M:%SZ',
                    rfc = '%a, %d %b %Y %H:%M:%S',
                    sortable = '%Y%m%d%H%M%S',
                    human = '%B %d, %Y %I:%M:%S %p',
                    short = '%m/%d/%y %H:%M:%S',
                    long = '%A, %B %d, %Y %I:%M:%S %p',
                    epoch = '%s',
                },
                date = {
                    iso = '%Y-%m-%d',
                    rfc = '%a, %d %b %Y',
                    sortable = '%Y%m%d',
                    human = '%B %d, %Y',
                    short = '%m/%d/%y',
                    long = '%A, %B %d, %Y',
                    epoch = '%s',
                },
                time = {
                    iso = '%H:%M:%S',
                    rfc = '%H:%M:%S',
                    sortable = '%H%M%S',
                    human = '%I:%M:%S %p',
                    short = '%H:%M:%S',
                    long = '%%I:%M:%S %p',
                },
            },
            default_formats = {
                datetime = 'iso',
                date = 'iso',
                time = 'iso',
            },
        },
        email = {
            domains = { 'example', 'company', 'mail', 'test', 'random' },
            tlds = { 'com', 'net', 'org', 'dev', 'edu' },
            digits = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' },
            specials = { '!', '#', '$', '%', '^', '&', '*' },
            separators = { '_', '-', '.' },
            default_digits = 0,
            default_specials = 0,
            default_muddle_property = 0.0,
        },
        float = {
            default_start = 1,
            default_stop = 100,
            default_decimals = 2,
        },
        int = {
            default_start = 1,
            default_stop = 100,
        },
        lorem = {
            corpuses = {
                ['lorem'] = 'words_lorem.txt',
            },
            sentence_lengths = {
                ['short'] = { 5, 20 },
                ['medium'] = { 20, 40 },
                ['long'] = { 40, 60 },
                ['mixed-short'] = { 5, 30 },
                ['mixed'] = { 5, 100 },
                ['mixed-long'] = { 30, 100 },
            },
            default_corpus = 'lorem',
            default_sentence_length = 'mixed-short',
            default_comma_property = 0.1,
            default_length = 100,
        },
        name = {
            FIRST = 'names_first.txt',
            LAST = 'names_last.txt',
        },
        url = {
            protocols = { 'http', 'https' },
            tlds = { 'com', 'org', 'net', 'edu', 'gov' },
            default_domain_corpus = 'medium',
            default_subdomain_corpus = 'short',
            default_path_corpus = 'medium',
            default_fragment_corpus = 'long',
            default_param_corpus = 'medium',
            default_value_corpus = 'medium',
            default_subdomains = 0,
            default_paths = 0,
            default_query_params = 0,
        },
        word = {
            corpuses = {
                ['short'] = 'words_short.txt',
                ['medium'] = 'words_medium.txt',
                ['long'] = 'words_long.txt',
            },
            default_corpus = 'medium',
            default_length = 1,
        },
    },
}
