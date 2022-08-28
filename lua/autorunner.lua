A = {}
A.autorun_bufnr = -1
A.autorun_data = {}
-- TODO: Let's create an option to create this file
A.command = "./.buildme.sh"
A.current_term = nil
A.term_size = 50
A.term_direction = "vertical"

local Terminal = require("toggleterm.terminal").Terminal

local notify_inform = function(msg, opts)
  local opt = opts or vim.log.levels.INFO
  vim.api.nvim_notify(msg, opt, {})
end

local append_data = function(_, _data)
  if #_data ~= 0 then
    for _, l in ipairs(_data) do
      table.insert(A.autorun_data, l)
    end
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, -1, -1, false, _data)
  end
end

local function call_autorun(command, data)
  local change_settings = function() vim.cmd("setlocal signcolumn=no") end
  if A.autorun_bufnr == -1 then
    -- TODO: Add options here, for the type of split
    vim.api.nvim_command("vnew")
    A.autorun_bufnr = vim.api.nvim_get_current_buf()
    -- FIXME: This is probably (or surely) bad, give users the access to this, maybe?
    vim.api.nvim_buf_set_keymap(
      A.autorun_bufnr,
      "n",
      "q",
      ":lua require('autorunner').clear_buffer()<CR>",
      { noremap = true, silent = true }
    )
    vim.keymap.set("n", "<Esc>", A.clear_buffer, { noremap = true, silent = true })
  end
  vim.api.nvim_buf_call(A.autorun_bufnr, change_settings)

  -- FIXME: The message here is personalized, for the plugin, I need to allow users to set it.
  vim.api.nvim_buf_set_lines(A.autorun_bufnr, 0, -1, false, { "OUTPUT from " .. A.command })
  if #data ~= 0 then
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, 0, -1, false, data)
    A.autorun_data = data
  else
    vim.fn.jobstart(command, {
      stderr_buffered = true,
      stdout_buffered = true,
      on_stdout = append_data,
      on_stderr = append_data,
    })
  end
end

-- Source: https://stackoverflow.com/a/4991602
local function check_if_file_exists(fname)
  -- attempt to open the file
  local f = io.open(fname, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function A.run()
  A.autorun_data = {}
  vim.api.nvim_create_augroup("autorun-krs", { clear = true })
  call_autorun(A.command, A.autorun_data)
end

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
end

function A._close_term()
  A.current_term:close()
  A.current_term = nil
end

function A.term_run()
  if A.current_term == nil then
    A.current_term = Terminal:new({
      start_in_insert=false,
      on_exit = function() A.current_term = nil end,
      terminal_mappings = true,
      insert_mappings = true,
      direction = tostring(A.term_direction),
      close_on_exit=true,
      size = A.term_size,
      -- hidden=true,
    })
    A.current_term:toggle()
    A.current_term:clear()
  elseif not A.current_term:is_open() then
    A.current_term:toggle()
    A.current_term:clear()
  else
    A.current_term:toggle()
    A.current_term:resize(A.term_size)
    A.current_term:toggle()
    A.current_term:send(A.command, false)
    return
  end

  A.current_term:send(A.command, true)
end

function A.term_toggle()
  if A.current_term == nil then
    A.term_run()
  elseif not A.current_term:is_open() then
    A.current_term = nil
    A.term_run()
  else
    A.current_term:toggle()
    A.current_term = nil
  end
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

function A.toggle()
  local function check_not_in_bufs_list(bufnumber)
    local bufs = vim.api.nvim_list_bufs()
    for _, l in ipairs(bufs) do
      if l == bufnumber then return false end
    end
    return true
  end

  if A.autorun_bufnr == -1 then
    call_autorun(A.command, A.autorun_data)
  elseif check_not_in_bufs_list(A.autorun_bufnr) then
    A.autorun_bufnr = -1
    call_autorun(A.command, A.autorun_data)
  else
    vim.api.nvim_notify(
      "Buffer already opened with bufnr: " .. A.autorun_bufnr,
      vim.log.levels.INFO,
      {}
    )
  end
end

function A.edit_file()
  if A.command ~= "" then
    -- Check if file can be opened
    if check_if_file_exists(A.command) then
      vim.api.nvim_command("e " .. A.command)
    else
      vim.api.nvim_notify(
        "File not found, path considered: "
          .. A.command
          .. ", if you want to change, use .add_command() method",
        vim.log.levels.ERROR,
        {}
      )
    end
  else
    vim.api.nvim_notify("Command not registered, use .add_command()", vim.log.levels.ERROR, {})
  end
end

function A.clear_buffer()
  if A.autorun_bufnr == -1 then
    vim.api.nvim_notify("Buffer not opened yet, do .toggle() or .run()", vim.log.levels.ERROR, {})
    return
  end
  vim.api.nvim_buf_delete(A.autorun_bufnr, {
    force = true,
  })
  A.autorun_bufnr = -1
end

function A.add_command()
  A.command = vim.fn.input("Input command: ")
  vim.api.nvim_notify("Command registered: " .. A.command, vim.log.levels.INFO, {})
end

function A.clear_command_and_buffer()
  A.command = ""
  A.clear_buffer()
end

function A.print_command()
  vim.api.nvim_notify("Command available: " .. A.command, vim.log.levels.INFO, {})
end

function A.set_term_size()
  -- TODO: Add a check if it's valid - directly converting to a number is not right
  A.term_size = tonumber(vim.fn.input("Input size for your current session: "))
  notify_inform("Size of your terminal is set to: " .. tostring(A.term_size))
end

function A.set_term_direction()
  -- TODO: Add a check if it's valid
  A.term_direction =
    vim.fn.input("Input direction for your current session: (horizontal/float/vertical) ")
  notify_inform("direction of your terminal is set to: " .. tostring(A.term_direction))
end

function A.get_term_properties()
  notify_inform("Terminal direction: " .. A.term_direction .. " and Terminal size: " .. A.term_size)
end

return A
