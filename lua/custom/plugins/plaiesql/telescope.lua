local M = {}

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

M.database_object_picker = function(opts)
  opts = opts or {}

  local get_client = function()
    local clients = vim.lsp.get_clients()
    -- local clients = vim.lsp.get_clients({ bufnr = 0 })

    for _, client in ipairs(clients) do
      if vim.startswith(client.name, 'plaiesql') then
        return client
      end
    end

    return nil
  end

  local client = get_client()

  if client == nil then
    vim.notify('No PLaieSQL client found.', vim.log.levels.ERROR)
    return
  end

  local read_object = function(object_name, new_bufnr_use)
    client:request('database/describe', object_name, function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end

      if result then
        local new_bufnr = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(new_bufnr, object_name)
        vim.api.nvim_set_option_value('filetype', 'plsql', { buf = new_bufnr })
        vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, result)
        vim.lsp.buf_attach_client(new_bufnr, client.id)
        new_bufnr_use(new_bufnr)
      end
    end)
  end

  client:request('database/listObjects', nil, function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify('No objects found', vim.log.levels.WARN)
      return
    end

    local finder = finders.new_table {
      results = result,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end
    }

    pickers.new(opts, {
      prompt_title = 'Database objects',
      finder = finder,
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          read_object(selection.value, function(bufnr)
            vim.api.nvim_set_current_buf(bufnr)
          end)
        end)
        return true
      end,
    }):find()
  end)
end

return M
