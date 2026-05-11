vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showmode = false
vim.o.winborder = "rounded"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.background = "dark"
vim.diagnostic.config({ virtual_lines = { current_line = true } })
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/olical/conjure",
	"https://github.com/hiphish/rainbow-delimiters.nvim",
	"https://github.com/neanias/everforest-nvim",
	"https://github.com/folke/lazydev.nvim"
})

require('lazydev').setup({})

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
}, {
	version = "main",
})

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "@string.special.symbol.clojure", { link = "Red" })
	end,
})

require("everforest").setup({})
vim.cmd("colorscheme everforest")

local ensure_installed = {
	"c",
	"lua",
	"markdown",
	"markdown_inline",
	"vimdoc",
	"scala",
	"haskell",
	"clojure"
}

local isnt_installed = function(lang)
	return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
end

local to_install = vim.tbl_filter(isnt_installed, ensure_installed)
if #to_install > 0 then
	require("nvim-treesitter").install(to_install)
end

-- Ensure tree-sitter enabled after opening a file for target language
local filetypes = {}
for _, lang in ipairs(ensure_installed) do
	for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
		table.insert(filetypes, ft)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Start treesitter",
	group = vim.api.nvim_create_augroup("start_treesitter", { clear = true }),
	pattern = filetypes,
	callback = function(ev)
		vim.treesitter.start(ev.buf)
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch", -- see `:highlight` for more options
			timeout = 200,
		})
	end,
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("hls")
vim.lsp.enable("clojure_lsp")

require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.surround').setup()
require('mini.comment').setup()
require('mini.snippets').setup()
require('mini.completion').setup()
require('mini.cursorword').setup()
-- require('mini.pairs').setup()
local git = require('mini.git')
git.setup()
local pick = require('mini.pick')
pick.setup()
local extra = require('mini.extra')
extra.setup()

vim.keymap.set('n', '<leader>ff', function()
	local git_data = git.get_buf_data(0)
	if (git_data ~= nil and next(git_data) ~= nil) then
		pick.builtin.files({ tool = 'git' })
	else
		pick.builtin.files()
	end
end, { noremap = true })

vim.keymap.set('n', '<leader>fg', pick.builtin.grep_live, { noremap = true })
vim.keymap.set('n', '<leader>fc', extra.pickers.commands, { noremap = true })
vim.keymap.set('n', '<leader>fd', extra.pickers.diagnostic, { noremap = true })
vim.keymap.set('n', '<leader>fk', extra.pickers.keymaps, { noremap = true })
vim.keymap.set('n', '<leader>fw', function()
	extra.pickers.lsp({ scope = 'workspace_symbol' })
end, { noremap = true })
vim.keymap.set('n', '<leader>fW', function()
	extra.pickers.lsp({ scope = 'document_symbol' })
end, { noremap = true })
vim.keymap.set('n', '<leader>fr', function()
	extra.pickers.lsp({ scope = 'references' })
end, { noremap = true })

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true })
vim.keymap.set('n', 'gq', vim.lsp.buf.format, { noremap = true })

vim.g["conjure#log#hud#enabled"] = false
vim.g["conjure#mapping#doc_word"] = false

vim.api.nvim_create_user_command("GetToplevel",
	function(_)
		require("lemming").get_toplevel()
	end,
	{ desc = "My epic command." })
