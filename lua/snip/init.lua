local util = require('snip.util')

---@class Config
---@field snippets_dir string Path to the snippets directory.
---@field ft_map table<string, string> Map of filetype aliases. This allows for multiple filetypes to map to the same snippet filetype directory.
---@field global_dirname string Directory name for global snippets. This lives inside the main snippets_dir
local config = {
  snippets_dir = vim.fn.stdpath('config') .. '/snippets',
  ft_map = {},
  global_dirname = '_global',
}

local snip = {}

---Overrides default configuration values.
---
---@param opts? Config Configuration overrides.
function snip.setup(opts)
  config = vim.tbl_extend('keep', opts or {}, config)
end

---@class PickOpts
---@field exclude_global boolean Don't include global snippets in the pick list.

---Interactively pick a snippet to expand.
---
---@param opts? PickOpts
function snip.pick(opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    exclude_global = false,
  })

  local ft = vim.o.filetype
  ft = config.ft_map[ft] or ft
  local snippets = {}
  if ft then
    snippets = snip.list_for_ft(ft)
  end

  ---@class Item
  ---@field text string
  ---@field filename string
  ---@field ft string

  ---@type Item[]
  local items = {}

  for _, s in ipairs(snippets) do
    ---@type Item
    local item = { text = 'ft: ' .. s.filename, filename = s.filename, ft = s.filetype }
    table.insert(items, item)
  end
  if not opts.exclude_global then
    for _, s in ipairs(snip.list_for_ft(config.global_dirname)) do
      ---@type Item
      local item = {
        text = 'global: ' .. s.filename,
        filename = s.filename,
        ft = s.filetype,
      }
      table.insert(items, item)
    end
  end
  if #items == 0 then
    vim.notify('no snippets found for filetype ' .. ft)
    return
  end

  vim.ui.select(
    items,
    {
      format_item = function(item)
        return item.text
      end,
    },
    ---@param item Item
    function(item)
      if item then
        snip.expand(util.mk_path(config.snippets_dir, item.ft, item.filename))
      end
    end
  )
end

---@class Snippet
---@field filename string The name of the snippet file.
---@field filetype string The filetype the snippet should be used for.
---@field path string The full path to the snippet file.

---Lists available snippets for the given filetype.
---
---@param ft string Filetype to list snippets for.
---@return Snippet[] snippets List of snippets.
function snip.list_for_ft(ft)
  assert(ft ~= nil and #ft > 0, 'ft is required')

  local dir = util.mk_path(config.snippets_dir, ft)
  if vim.fn.isdirectory(dir) == 0 then
    return {}
  end

  ---@type string[]
  local snippets = {}
  for f, t in vim.fs.dir(dir) do
    if t == 'file' then
      ---@type Snippet
      local s = {
        filename = f,
        filetype = ft,
        path = util.mk_path(config.snippets_dir, ft, f)
      }
      table.insert(snippets, s)
    end
  end

  return snippets
end

---Expands a snippet file into the current active buffer.
---
---@param path string  Absolute path to the snippet source file.
function snip.expand(path)
  vim.snippet.expand(util.read_file(path))
end

return snip
