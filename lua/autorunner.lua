A = {}
A.autorun_bufnr = -1
A.autorun_data = ""
A.command = "./.buildme.sh"

local function call_autorun(command, data)
  local change_settings = function()
    vim.cmd "setlocal signcolumn=no nonumber"
  end
  if A.autorun_bufnr == -1 then
    vim.api.nvim_command "vnew | setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile"
    A.autorun_bufnr = vim.api.nvim_get_current_buf()
  end
  vim.api.nvim_buf_call(A.autorun_bufnr, change_settings)
  local append_data = function(_, _data)
    if _data then
      A.autorun_data = _data
    end
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, -1, -1, false, _data)
  end

  -- TODO: The message here is personalized, for the plugin, I need to allow users to set it.
  vim.api.nvim_buf_set_lines(A.autorun_bufnr, 0, -1, false, { "OUTPUT from " .. A.command })
  if data ~= "" then
    vim.api.nvim_buf_set_lines(A.autorun_bufnr, -1, -1, false, data)
    A.autorun_data = data
  else
    vim.fn.jobstart(command, {
      stdout_buffered = true,
      on_stdout = append_data,
      on_stderr = append_data,
    })
  end
end

-- vim.api.nvim_create_autocmd({ "BufLeave" }, {
--   callback = function()
--     if vim.api.nvim_get_current_buf() == A.autorun_bufnr then
--       -- vim.api.nvim_buf_detach()
--       vim.api.nvim_buf_delete(A.autorun_bufnr, {
--         force = true,
--       })
--       A.autorun_bufnr = -1
--     end
--   end,
-- })

function A.run()
  -- vim.api.nvim_command("vnew")
  -- call_autorun(vim.api.nvim_get_current_buf(), "./.buildme.sh")
  vim.api.nvim_create_augroup("autorun-krs", { clear = true })
  call_autorun(A.command, "")
end

function A.toggle()
  -- If it's not -1, then it means a window is already opened, so just ignore
  -- TODO: add a message
  if A.autorun_bufnr == -1 then
    if A.autorun_data ~= "" then
      call_autorun("", A.autorun_data)
    else
      call_autorun(A.command, "")
    end
  else
    vim.api.nvim_notify("Buffer already opened with bufnr: " .. A.autorun_bufnr, vim.log.levels.INFO, {})
  end
end

function A.edit_file()
  -- local ui = vim.api.nvim_list_uis()[1]
  if A.command ~= "" then
    -- Check if file is in the runtime dir
    local files = vim.api.nvim_get_runtime_file(A.command, true)
    if #files == 0 then
      vim.api.nvim_notify("Couldn't find " .. A.command .. " in the runtime directory", vim.log.levels.ERROR, {})
      return
    end
    vim.api.nvim_command("e " .. A.command)
  else
    vim.api.nvim_notify("Command not registered, use :AutoRunnerAddCommand", vim.log.levels.ERROR, {})
  end
end

function A.clear_buffer()
  -- if vim.api.nvim_get_current_buf() == A.autorun_bufnr then
  -- vim.api.nvim_buf_detach()
  if A.autorun_bufnr == -1 then
    vim.api.nvim_notify("Buffer not opened yet, do :AutoRunnerToggle or :AutoRunnerRun", vim.log.levels.ERROR, {})
    return
  end
  vim.api.nvim_buf_delete(A.autorun_bufnr, {
    force = true,
  })
  A.autorun_bufnr = -1
end

function A.add_command()
  A.command = vim.fn.input "Input command: "
  vim.api.nvim_notify("Command registered: " .. A.command, vim.log.levels.INFO, {})
end

function A.clear_command_and_buffer()
  A.command = ""
  vim.cmd("AutoRunnerClearBuffer")
end

function A.print_command()
  vim.api.nvim_notify("Command available: " .. A.command, vim.log.levels.INFO, {})
end

return A
