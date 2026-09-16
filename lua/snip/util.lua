local util = {}

function util.mk_path(base, ft, file)
  assert(base ~= nil and #base > 0, "base is required")
  local p = base
  if ft then
    p = vim.fs.joinpath(p ,ft)
  end
  if file then
    p = vim.fs.joinpath(p, file)
  end
  return p
end

function util.read_file(path)
  assert(#path > 0, "path is required")
  local f = io.open(path, 'r')
  if not f then
    error('file does not exist: ' .. path)
  end
  local content = f:read('a')
  f:close()
  return content
end

return util
