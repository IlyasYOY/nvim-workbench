local lualine = require "lualine"

local function fugitive_head()
    if vim.fn.exists "*FugitiveHead" == 0 then
        return ""
    end

    return vim.fn.FugitiveHead()
end

lualine.setup {
    options = {
        icons_enabled = false,
    },
    sections = {
        lualine_a = {
            "lsp_status",
        },
        lualine_b = {
            {
                fugitive_head,
                cond = function()
                    return fugitive_head() ~= ""
                end,
            },
        },
        lualine_c = {
            {
                "filename",
                path = 3,
            },
        },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
}
