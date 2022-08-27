A = {}
A.autorun_bufnr = -1
A.autorun_data = {}
A.command = "./.buildme.sh"

local function call_autorun(command, data)
	local change_settings = function()
		vim.cmd("setlocal signcolumn=no nonumber")
	end
	if A.autorun_bufnr == -1 then
		vim.api.nvim_command("vnew")
		A.autorun_bufnr = vim.api.nvim_get_current_buf()
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

-- vim.api.nvim_create_autocmd({ "BufLeave" }, {
-- 	callback = function()
-- 		if vim.api.nvim_get_current_buf() == A.autorun_bufnr then
-- 			vim.api.nvim_buf_delete(A.autorun_bufnr, {
-- 				force = false,
-- 			})
-- 			A.autorun_bufnr = -1
-- 		end
-- 	end,
-- })

function A.run()
	A.autorun_data = {}
	vim.api.nvim_create_augroup("autorun-krs", { clear = true })
	call_autorun(A.command, A.autorun_data)
end

function A.toggle()
	local function check_not_in_bufs_list(bufnumber)
		local bufs = vim.api.nvim_list_bufs()
		for _, l in ipairs(bufs) do
			if l == bufnumber then
				return false
			end
		end
		return true
	end

	if A.autorun_bufnr == -1 then
		call_autorun(A.command, A.autorun_data)
	elseif check_not_in_bufs_list(A.autorun_bufnr) then
		A.autorun_bufnr = -1
		call_autorun(A.command, A.autorun_data)
	else
		vim.api.nvim_notify("Buffer already opened with bufnr: " .. A.autorun_bufnr, vim.log.levels.INFO, {})
	end
end

function A.edit_file()
	if A.command ~= "" then
		-- Check if file is in the runtime dir
		local files = vim.api.nvim_get_runtime_file(A.command, true)
		if #files == 0 then
			vim.api.nvim_notify("Couldn't find " .. A.command .. " in the runtime directory", vim.log.levels.ERROR, {})
			return
		end
		vim.api.nvim_command("e " .. A.command)
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

-- Global mappings
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "q", A.clear_buffer, opts)
vim.keymap.set("n", "<Esc>", A.clear_buffer, opts)

return A
