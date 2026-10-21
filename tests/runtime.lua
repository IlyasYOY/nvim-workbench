for _, command in ipairs {
    "AgentReview",
    "SpellFix",
    "DapContinue",
    "ObsNvimNewNote",
} do
    assert(vim.fn.exists(":" .. command) == 0, command .. " is still available")
end

local retired_plugins = {
    "agent-review.nvim",
    "obs.nvim",
    "spellfix.nvim",
    "nvim-dap",
    "nvim-dap-go",
    "nvim-dap-python",
    "nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-jdtls",
    "nvim-nio",
    "plenary.nvim",
}
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
    for _, name in ipairs(retired_plugins) do
        assert(
            vim.fs.basename(path) ~= name,
            name .. " is still on runtimepath"
        )
    end
end

local core = require "ilyasyoy.functions.core"
assert(
    vim.fn.filereadable(
        core.resolve_relative_to_workbench "config/.golangci.yml"
    ) == 1
)

-- Exercise real FileType hooks after removing Java and debugger integrations.
for _, filetype in ipairs { "java", "go", "python" } do
    vim.cmd.enew()
    vim.bo.filetype = filetype
    for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
        assert(client.name ~= "jdtls", "Java language server is still active")
    end
    if filetype == "go" then
        assert(vim.fn.exists ":GoToggleTest" == 2)
    elseif filetype == "python" then
        assert(vim.fn.exists ":PythonToggleTest" == 2)
    else
        assert(vim.fn.exists ":JavaToggleTest" == 0)
    end
end

assert(vim.g.db_ui_save_location == vim.fn.getcwd() .. "/sql/")
assert(vim.fn.isdirectory(vim.g.db_ui_save_location) == 1)
vim.cmd.enew()
vim.bo.filetype = "sql"
assert(vim.bo.omnifunc == "vim_dadbod_completion#omni")
assert(vim.fn.exists ":DBUI" == 2)
vim.cmd.enew()
vim.bo.filetype = "markdown"
assert(vim.fn.maparg("<leader>nn", "n") == "")
assert(vim.fn.exists ":ObsNvimNewNote" == 0)
