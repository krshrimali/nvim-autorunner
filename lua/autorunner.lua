A = {}
A.autorun_bufnr = -1
A.autorun_data = {}
-- TODO: Let's create an option to create this file
A.command = "./.buildme.sh"

local function call_autorun(command, data)
  local change_settings = function() vim.cmd("setlocal signcolumn=no nonumber") end
  if A.autorun_bufnr == -1 then
    -- TODO: Add options here, for the type of split
    vim.api.nvim_command("vnew")
    A.autorun_bufnr = vim.api.nvim_get_current_buf()
    -- FIXME: This is probably (ore surely) bad, give users the access to this, maybe?
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
  local append_data = function(_, _data)
    if #_data ~= 0 then
      for _, l in ipairs(_data) do
        table.insert(A.autorun_data, l)
      end
    end
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, -1, -1, false, _data)
  end

  -- FIXME: The message here is personalized, for the plugin, I need to allow users to set it.
  vim.api.nvim_buf_set_lines(A.autorun_bufnr, 0, -1, false, { "OUTPUT from " .. A.command })
  if #data ~= 0 then
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, 0, -1, false, data)
    A.autorun_data = data
  else
    vim.fn.jobstart(command, {
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

return A
