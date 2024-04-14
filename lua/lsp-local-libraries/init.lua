--[[
Neovim folders -> see :h runtimepath
"lua" directory has code that is only executed on "require"
"plugin" directory has code that is executed right as neovim loads

To search for help functions, we can use telescope:
:Telescope help_tags

To fetch some function like "nvim_", you type:
vim.api.<name_of_function>()

To see the contents of a table, use:
print(vim_inspect(<table>))
--]]

local M = {}

CONFIG_FILE_NAME = ".nvim-lsp.json"

local function get_curr_buf_directory()
    local current_file = vim.api.nvim_buf_get_name(0)
    local _, _, current_directory = string.find(current_file, "(.*)/.*$")
    return current_directory
end

M.setup = function ()
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function (args)
            local current_directory = get_curr_buf_directory()
            local config_file_path = string.format("%s/%s", current_directory, CONFIG_FILE_NAME)
            local config_file = io.open(config_file_path, "r")
            if config_file ~= nil then
                print("Found the config file")
            end
        end
    })
end

return M
