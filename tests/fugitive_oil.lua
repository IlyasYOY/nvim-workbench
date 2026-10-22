local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
root = assert(vim.uv.fs_realpath(root))
local original_cwd = vim.fn.getcwd()
local oil = require "oil"

local function git_init(path, git_dir)
    vim.fn.mkdir(path, "p")
    local command = { "git", "init", "--quiet" }
    if git_dir then
        table.insert(command, "--separate-git-dir=" .. git_dir)
    end
    table.insert(command, path)
    local result = vim.system(command):wait()
    assert(result.code == 0, result.stderr)
end

local function open_oil(path)
    oil.open(path)
    assert(
        vim.wait(1000, function()
            return vim.bo.filetype == "oil"
                and oil.get_current_dir() == path .. "/"
                and vim.b.oil_ready
        end),
        "Oil did not open the nested directory"
    )
end

local function assert_repo(git_dir)
    assert(
        vim.uv.fs_realpath(vim.fn.FugitiveActualDir())
            == vim.uv.fs_realpath(git_dir),
        "Git from Oil selected "
            .. vim.fn.FugitiveGitDir()
            .. "; expected "
            .. git_dir
    )
end

local ok, err = pcall(function()
    -- Reproduce both a parent repo and a plain directory containing projects.
    for _, parent_is_repo in ipairs { true, false } do
        local base = root .. (parent_is_repo and "/base-repo" or "/projects")
        local project = base .. "/a"
        local nested = project .. "/c"
        local sibling = base .. "/other project"
        local separate_git_dir = root
            .. (parent_is_repo and "/git-one" or "/git-two")
        if parent_is_repo then
            git_init(base)
        end
        git_init(project)
        git_init(sibling, separate_git_dir)
        vim.fn.mkdir(nested, "p")
        vim.fn.writefile({ "example" }, nested .. "/example.txt")
        vim.cmd.cd(base)
        local cwd = vim.fn.getcwd()

        open_oil(nested)
        local oil_buf = vim.api.nvim_get_current_buf()
        vim.cmd.Git()
        assert(vim.bo.filetype == "fugitive", "Git did not open status")
        assert_repo(project .. "/.git")
        assert(vim.fn.getcwd() == cwd, "Git changed cwd")

        -- Gitfiles and spaces in paths must use Fugitive's own detection.
        open_oil(sibling)
        vim.cmd.Git()
        assert_repo(separate_git_dir)

        -- Re-enter an existing Oil buffer after visiting another repository.
        vim.api.nvim_set_current_buf(oil_buf)
        vim.cmd "Gedit :"
        assert_repo(project .. "/.git")

        vim.cmd.edit(nested .. "/example.txt")
        vim.cmd.Git()
        assert_repo(project .. "/.git")
        assert(vim.fn.getcwd() == cwd, "Oil navigation changed cwd")
    end
end)

vim.cmd.cd(original_cwd)
vim.cmd "silent! %bwipeout!"
vim.fn.delete(root, "rf")
assert(ok, err)
