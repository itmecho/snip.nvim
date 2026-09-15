---@class Config
---@field snippets_dir string Path to the snippets directory.
---@field ft_map table<string, string> Map of filetype aliases. This allows for multiple filetypes to map to the same snippet filetype directory.
---@field global_dirname string Directory name for global snippets. This lives inside the main snippets_dir
local config = {
  snippets_dir = vim.fn.stdpath('config') .. '/snippets',
  ft_map = {},
  global_dirname = '_global',
}

local function mk_path(ft, file)
  local p = config.snippets_dir
  if ft then
    p = vim.fs.joinpath(p ,ft)
  end
  if file then
    p = vim.fs.joinpath(p, file)
  end
  return p
end

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

  local ft = vim.opt.filetype:get()
  ft = config.ft_map[ft] or ft
  local files = snip.list_for_ft(ft)

  ---@class Item
  ---@field text string
  ---@field filename string
  ---@field ft string

  ---@type Item[]
  local items = {}

  for _, f in ipairs(files) do
    ---@type Item
    local item = { text = 'ft: ' .. f, filename = f, ft = ft }
    table.insert(items, item)
  end
  if not opts.exclude_global then
    for _, f in ipairs(snip.list_for_ft(config.global_dirname)) do
      ---@type Item
      local item = {
        text = 'global: ' .. f,
        filename = f,
        ft = config.global_dirname,
      }
      table.insert(items, item)
    end
  end
  if #files == 0 then
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
        snip.expand(mk_path(item.ft, item.filename))
      end
    end
  )
end

---Lists available snippet files for the given filetype.
---
---@param ft string  Filetype to list snippets for.
---@return string[] filenames List of snippet filenames.
function snip.list_for_ft(ft)
  assert(ft ~= nil and #ft > 0, 'ft is required')

  local dir = mk_path(ft)
  if vim.fn.isdirectory(dir) == 0 then
    return {}
  end

  ---@type string[]
  local files = {}
  for f, t in vim.fs.dir(dir) do
    if t == 'file' then
      table.insert(files, f)
    end
  end

  return files
end

---Expands a snippet file into the current active buffer.
---
---@param path string  Absolute path to the snippet source file.
function snip.expand(path)
  local f = io.open(path, 'r')
  if not f then
    error('file does not exist: ' .. path)
  end
  local content = f:read('a')
  f:close()
  vim.snippet.expand(content)
end

return snip
