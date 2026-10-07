local config_dir = vim.fs.dirname(vim.fn.resolve(vim.fn.stdpath "config"))

require("dispatch-kit").setup {
    makeprg = {
        bang = false,
        silent = false,
    },
    adapters = {
        go = {
            golangci = {
                fallback_config = vim.fs.joinpath(config_dir, ".golangci.yml"),
            },
        },
        python = true,
        javascript = true,
        proto = true,
        make = true,
    },
}
