local M = {
  path_to_plaiesql = '/path/to/PlaieSQL/app/build/install/app/bin/app',
  default_user = 'default_user',
  default_password = 'default_password',
}

local module_prefix = (...):match('(.-)[^%.]+$') or ''
local lsp = require(module_prefix .. 'plaiesql.lsp')
local telescope = require(module_prefix .. 'plaiesql.telescope')

M.find_database_object = telescope.database_object_picker

M.enable = function()
  vim.filetype.add {
    extension = {
      fnc = 'plsql',
      FNC = 'plsql',
      pks = 'plsql',
      PKS = 'plsql',
      pkb = 'plsql',
      PKB = 'plsql',
      prc = 'plsql',
      PRC = 'plsql',
      sql = 'plsql',
      SQL = 'plsql',
      trg = 'plsql',
      TRG = 'plsql',
      vw = 'plsql',
      VW = 'plsql',
    },
  }

  lsp.path_to_plaiesql = M.path_to_plaiesql
  lsp.default_user = M.default_user
  lsp.default_password = M.default_password
  lsp.config_and_enable()
end

M.use_default_keymaps = function()
  vim.keymap.set('n', '<leader>da', '<cmd>CurrentConnection<cr>', { desc = 'Get current connection name.' })
  vim.keymap.set('n', '<leader>dl', '<cmd>ListTnsNames<cr>', { desc = 'List all available TNS names.' })
  vim.keymap.set('n', '<leader>dc', '<cmd>ExecuteFile<cr>', { desc = 'Execute the current file using the current database connection.' })

  vim.keymap.set('n', '<leader>ds', M.find_database_object, { desc = 'Search among all database objects.' })
end

return M
