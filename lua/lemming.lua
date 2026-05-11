local M = {}

local function fetch_items(callback)
	vim.system({
		"curl",
		"-X",
		"GET",
		"http://localhost:8080/toplevel",
	}, {
		text = true,
	}, function(obj)
		if obj.code ~= 0 then
			vim.schedule(function()
				vim.notify(obj.stderr, vim.log.levels.ERROR)
			end)
			return
		end

		local ok, decoded = pcall(vim.json.decode, obj.stdout)

		if not ok then
			vim.schedule(function()
				vim.notify("Invalid JSON response", vim.log.levels.ERROR)
			end)
			return
		end

		vim.schedule(function()
			callback(decoded)
		end)
	end)
end

function send_buffer(bufno, callback)
	local text = table.concat(vim.api.nvim_buf_get_lines(bufno, 0, -1, false), "\n")
	local data = {
		id = vim.bo[bufno].ajsid,
		content = text
	}
	vim.system({
		"curl",
		"--json",
		vim.json.encode(data),
		"http://localhost:8080/upload",
	}, {
		text = true,
	}, function(obj)
		if obj.code ~= 0 then
			vim.schedule(function()
				vim.notify(obj.stderr, vim.log.levels.ERROR)
			end)
			return
		end

		local ok, decoded = pcall(vim.json.decode, obj.stdout)

		if not ok then
			vim.schedule(function()
				vim.notify("Invalid JSON response", vim.log.levels.ERROR)
			end)
			return
		end

		vim.schedule(function()
			callback(decoded)
		end)
	end)
end

function create_buffer(data)
	local buf = vim.api.nvim_create_buf(true, false)
	vim.bo[buf]["ajsid"] = data.id
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(data.text, "\n", { plain = true }))
	return buf
end

function M.get_toplevel()
	fetch_items(function(items)
		vim.ui.select(items, {
			prompt = "Select top level header:",
			format_item = function(item)
				return item.title
			end,
		}, function(choice)
			print(vim.inspect(choice))
		end)
	end)
end

return M
