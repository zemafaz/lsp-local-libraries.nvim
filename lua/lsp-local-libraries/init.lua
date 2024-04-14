local lspconfig = require("lspconfig")
local Path = require("plenary.path")


CONFIG_FILE_NAME = ".nvim-lsp.json"
SUPPORTED_CLIENTS = { "jsonls" }
CONFIG_SCHEMA_PATH = Path:new("./schemas/config-schema.json"):absolute()


local M = {}


local function jsonls_append_schema(schema)
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
    jsonls_append_schema(config_file_schema)
end


local function jsonls_setup_config(config)
    for i, _ in ipairs(config) do
        local absolute_path = Path:new(config[i].url):absolute()
        config[i].url = absolute_path
        jsonls_append_schema(config[i])
    end
end


local function setup()
    -- Add .nvim-lsp.json JSON schemas to the LSP schemas
    add_config_file_schema()

    -- Get possible config file path
    local config_file_path = vim.api.nvim_buf_get_name(0)
    if Path:new(config_file_path):is_dir() then
        config_file_path = Path:new(config_file_path .. "/" .. CONFIG_FILE_NAME):absolute()
    else
        local parent_folder_path = Path:new(config_file_path):parent()
        config_file_path = Path:new(parent_folder_path .. "/" .. CONFIG_FILE_NAME):absolute()
    end

    -- Open file
    local config_file = io.open(config_file_path)
    if not config_file then
        return 1
    end

    -- Read and decode json config
    local json = require("lsp-local-libraries.json")
    local ok, config = pcall(json.decode, config_file:read("*a"))
    if not ok then
        print("Error parsing .nvim-lsp.json config")
    end

    -- Interpret configuration for jsonls
    if config.jsonls then
        jsonls_setup_config(config.jsonls)
    end

    return 0
end


M.setup = setup
return M
