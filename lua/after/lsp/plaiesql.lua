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

local function process_server_response(err, result)
  if err then
    vim.notify(err.message, vim.log.levels.ERROR)
    return
  end

  if result then
    vim.notify(vim.inspect(result), vim.log.levels.INFO)
  end
end

local function open_connection(client, opts)
  local connection_name = string.match(opts.args, "^(%S+)")

  local params = {
    connectionName = connection_name,
    user = default_user,
    password = default_password,
  }

  local remaining_args = string.sub(opts.args, #connection_name + 1)

  for arg in string.gmatch(remaining_args, '%S+') do
    local key, value = string.match(arg, '([^=]+)=([^=]+)')
    if key and params[key] ~= nil then
      params[key] = value
    end
  end

  client:request('database/openConnection', params, function(err, result)
    process_server_response(err, result)
  end)
end

local function current_connection(client)
  client:request('database/currentConnection', nil, function(err, result)
    process_server_response(err, result)
  end)
end

local function list_tns_names(client)
  client:request('database/listNames', nil, function(err, result)
    process_server_response(err, result)
  end)
end

local function close_connection(client, opts)
  local params = {
    connectionName = opts.args,
  }

  client:request('database/closeConnection', params, function(err, result)
    process_server_response(err, result)
  end)
end

local function execute_file(client, bufnr)
  local params = {
    script = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
  }

  client:request('database/execute', params, function(err, result)
    process_server_response(err, result)
  end)
end

vim.lsp.config['plaiesql'] = {
  cmd = { path_to_plaiesql },
  filetypes = { 'sql', 'plsql' },
  root_dir = vim.loop.cwd(),
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'OpenConnection', function(opts)
      open_connection(client, opts)
    end, {
      nargs = '+',
      desc = 'Connect to a database.',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'CurrentConnection', function()
      current_connection(client)
    end, {
      desc = 'Get current connection name.',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'ListTnsNames', function()
      list_tns_names(client)
    end, {
      desc = 'List all available TNS names.',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'CloseConnection', function(opts)
      close_connection(client, opts)
    end, {
      nargs = 1,
      desc = 'Close a database connection.',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'ExecuteFile', function()
      execute_file(client, bufnr)
    end, {
      desc = 'Execute the current file using the current database connection.',
    })
  end,
}

vim.lsp.enable 'plaiesql'

-- Usefull keymaps
vim.keymap.set('n', '<leader>dba', '<cmd>CurrentConnection<cr>', { desc = 'Get current connection name.' })
vim.keymap.set('n', '<leader>dbl', '<cmd>ListTnsNames<cr>', { desc = 'List all available TNS names.' })
vim.keymap.set('n', '<leader>dbc', '<cmd>ExecuteFile<cr>', { desc = 'Execute the current file using the current database connection.' })
