local snip = require("snip")
local util = require("snip.util")

--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

-- `opts` table comes from `sources.providers.your_provider.opts`
-- You may also accept a second argument `config`, to get the full
-- `sources.providers.your_provider` table
function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = opts
	return self
end

-- (Optional) Enable the source in specific contexts only
function source:enabled()
	local snippets = snip.list_for_ft(vim.o.filetype)
	return #snippets > 0
end

function source:get_completions(_, callback)
	---@type Snippet[]
	local snippets = snip.list_for_ft(vim.o.filetype)

	--- @type lsp.CompletionItem[]
	local items = {}
	for _, s in ipairs(snippets) do
		local content = util.read_file(s.path)
		--- @type lsp.CompletionItem
		local item = {
			label = s.filetype .. ": " .. s.filename,
			data = s,
			insertText = content,
			documentation = content,
			insertTextFormat = 2,
		}
		table.insert(items, item)
	end

	callback({
		items = items,
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})

	return function() end
end

return source
