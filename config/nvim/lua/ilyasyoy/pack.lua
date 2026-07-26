local gh = function(x)
    return "https://github.com/" .. x
end

local function is_dir(path)
    return vim.fn.isdirectory(path) == 1
end

-- Dev plugins: use local path if it exists, else fall back to GitHub.
local function ilyasyoy(name, opts)
    opts = opts or {}
    local local_path =
        vim.fn.expand(opts.path or ("~/Projects/IlyasYOY/" .. name))

    if not is_dir(local_path) then
        return gh("IlyasYOY/" .. name)
    end

    if opts.live then
        vim.opt.runtimepath:prepend(local_path)

        local after = local_path .. "/after"
        if is_dir(after) then
            vim.opt.runtimepath:append(after)
        end

        return { dev = true, live = true, name = name, path = local_path }
    end

    return { src = "file://" .. local_path, name = name }
end

local function pack_specs(specs)
    return vim.iter(specs)
        :filter(function(spec)
            return not (type(spec) == "table" and spec.live)
        end)
        :totable()
end

local function pack_name(spec)
    if type(spec) == "table" and spec.name then
        return spec.name
    end

    local src = type(spec) == "table" and spec.src or spec
    local name = vim.fs.basename(src):gsub("%.git$", "")
    return name
end

local function personal_plugin_specs()
    local manifest =
        vim.fs.joinpath(vim.fn.stdpath "config", "personal-plugins.txt")
    local specs = {}

    for _, name in ipairs(vim.fn.readfile(manifest)) do
        name = vim.trim(name)
        if name ~= "" and not vim.startswith(name, "#") then
            table.insert(specs, ilyasyoy(name, { live = true }))
        end
    end

    return specs
end

local function install_firenvim(ev)
    local data = ev.data
    if data.spec.name ~= "firenvim" then
        return
    end

    if data.kind ~= "install" and data.kind ~= "update" then
        return
    end

    if not data.active then
        vim.cmd.packadd "firenvim"
    end

    vim.fn["firenvim#install"](0)
end

local function update_nvim_treesitter(ev)
    local data = ev.data
    if data.spec.name ~= "nvim-treesitter" or data.kind ~= "update" then
        return
    end

    if not data.active then
        vim.cmd.packadd "nvim-treesitter"
    end

    assert(
        require("nvim-treesitter").update():wait(300000),
        "nvim-treesitter parser update failed"
    )
end

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        install_firenvim(ev)
        update_nvim_treesitter(ev)
    end,
})

local M = {
    specs = {
        gh "jamessan/vim-gnupg",
        gh "glacambre/firenvim",
        gh "f-person/auto-dark-mode.nvim",
        gh "christoomey/vim-tmux-navigator",
        gh "nvim-lualine/lualine.nvim",
        gh "L3MON4D3/LuaSnip",
        gh "neovim/nvim-lspconfig",
        gh "williamboman/mason.nvim",
        gh "WhoIsSethDaniel/mason-tool-installer.nvim",
        gh "nvim-treesitter/nvim-treesitter",
        {
            src = gh "nvim-treesitter/nvim-treesitter-textobjects",
            version = "main",
        },
        gh "nvim-treesitter/nvim-treesitter-context",
        gh "nvim-lua/plenary.nvim",
        gh "tpope/vim-abolish",
        gh "ibhagwan/fzf-lua",
        gh "stevearc/oil.nvim",
        gh "mfussenegger/nvim-dap",
        gh "theHamsta/nvim-dap-virtual-text",
        gh "nvim-neotest/nvim-nio",
        gh "rcarriga/nvim-dap-ui",
        gh "leoluz/nvim-dap-go",
        gh "mfussenegger/nvim-dap-python",
        gh "mfussenegger/nvim-jdtls",
        gh "tpope/vim-dadbod",
        gh "kristijanhusak/vim-dadbod-completion",
        gh "kristijanhusak/vim-dadbod-ui",
        gh "tpope/vim-dispatch",
        gh "shumphrey/fugitive-gitlab.vim",
        gh "tommcdo/vim-fubitive",
        gh "tpope/vim-rhubarb",
        gh "tpope/vim-fugitive",
    },
}

vim.list_extend(M.specs, personal_plugin_specs())
local active_specs = pack_specs(M.specs)
M.update_names = vim.iter(active_specs):map(pack_name):totable()

function M.update()
    return vim.pack.update(M.update_names, { force = true })
end

vim.pack.add(active_specs)

return M
