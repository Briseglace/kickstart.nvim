local path_to_plaiesql = '/home/briseglace/Code/PlaieSQL/app/build/install/app/bin/app'
local default_user = 'plaiesql'
local default_password = 'test'

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

local function connect_to_database(opts)
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'plaiesql' })

  if #clients == 0 then
    vim.notify('PLaieSQL client not running or not found', vim.log.levels.WARN)
    return
  end
  local client = clients[1]

  local connection_name = string.match(opts.args, "^(%S+)")

  local params = {
    connectionName = connection_name,
    user = default_user,
    password = default_password,
  }

  local remaining_args = string.sub(opts.args, #connection_name + 1)

  for arg in string.gmatch(remaining_args, "%S+") do
    local key, value = string.match(arg, "([^=]+)=([^=]+)")
    if key and params[key] ~= nil then
      params[key] = value
    end
  end

  client:request('database/connectTo', params, function(err, result)
    if err then
      vim.notify('LSP Error: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    if result then
      vim.notify('Server responded: ' .. vim.inspect(result), vim.log.levels.INFO)
    end
  end)
end

vim.lsp.config['plaiesql'] = {
  cmd = { path_to_plaiesql },
  filetypes = { 'sql', 'plsql' },
  root_dir = vim.loop.cwd(),
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'ConnectToDatabase', function(opts)
      connect_to_database(opts)
    end, {
      nargs = '+',
      desc = 'Connect to a database',
    })
  end,
}
vim.lsp.enable 'plaiesql'
