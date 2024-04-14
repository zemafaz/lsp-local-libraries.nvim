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

<status>, <function_return> = pcall(<func>, ...<args>) <- calls function in protected mode, i.e.:
    if the function errors, it is catched on the <status> and does not propagate

: (colon) operator passes the self as the first argument
--]]

local M = {}

CONFIG_FILE_NAME = ".nvim-lsp.json"
SUPPORTED_CLIENTS = { "jsonls" }
CONFIG_SCHEMA_PATH = require("plenary.path")
    :new("./schemas/config-schema.json")
    :absolute()

local lspconfig = require("lspconfig")

local function check_if_elem_in_list(elem, list)
    for _, list_elem in ipairs(list) do
        if elem == list_elem then
            return true
        end
    end
    return false
end

local function get_buf_directory(bufn)
    local current_file = vim.api.nvim_buf_get_name(bufn)
    local current_directory
    _, _, current_directory, current_file = string.find(current_file, "(.*)/(.*)$")
    return current_directory, current_file
end

local function append_json_schemas(schema)
    local current_schema = lspconfig.jsonls.manager.config.settings.json.schemas
    if current_schema then
        table.insert(current_schema, schema)
    else
        current_schema = schema
    end
    lspconfig.jsonls.manager.config.settings.json.schemas = current_schema
end

local function add_config_file_schema()
    local config_file_schema = {
        fileMatch = { CONFIG_FILE_NAME },
        url = CONFIG_SCHEMA_PATH
    }
    append_json_schemas(config_file_schema)
end

local function setup()

    add_config_file_schema()

    for _, workspace_directory in ipairs(vim.lsp.buf.list_workspace_folders()) do
        local config_file = io.open(workspace_directory .. "/" .. CONFIG_FILE_NAME)
        if not config_file then
            goto continue
        end
        ::continue::
    end


    -- vim.api.nvim_create_autocmd("LspAttach", {
    --     callback = function (args)
    --
    --         -- Check supportted LSP
    --         local client = vim.lsp.get_client_by_id(args.data.client_id)
    --         if not check_if_elem_in_list(client.name, SUPPORTED_CLIENTS) then
    --             return nil
    --         end
    --
    --         -- Opening config file
    --         local current_directory = get_buf_directory(args.buf)
    --         local config_file_path = string.format("%s/%s", current_directory, CONFIG_FILE_NAME)
    --         local config_file = io.open(config_file_path, "r")
    --         if config_file == nil then
    --             return nil
    --         end
    --
    --         -- Reading config file
    --         local json = require("lsp-local-libraries.json")
    --         local config = json.decode(config_file:read("*a"))
    --         config_file:close()
    --
    --         if config["jsonls"] then
    --             local patterns = config["jsonls"]
    --             for pattern, schemas_path_list in pairs(patterns) do
    --                 print(pattern .. " : " .. vim.inspect(schemas_path_list))
    --             end
    --         end
    --     end
    -- })
end

M.setup = setup

return M
