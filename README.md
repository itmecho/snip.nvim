# snip.nvim

Just a basic Neovim plugin wrapper around the builtin `vim.snippet` API.

## Snippet directory structure

```
~/.config/nvim/snippets/
└── <filetype>/
    └── <some-snippet-file>
```

The plugin doesn't care what the filetype of the snippet file is so you can
name the file how you want and then write the snippet with syntax highlighting!

```
~/.config/nvim/snippets/
└── go/
    └── iferr.go
```

## Usage

The plugin exposes a few basic functions for working with the snippets:

```lua
require('snip').pick() -- Interactively select a snippet for the current file type
require('snip').list_for_ft(filetype) -- List available snippets for a filetype
require('snip').expand(file) -- Expand a snippet from a file
```

You could then create a keymap to select a snippet like this:

```lua
vim.keymap.set('i', '<c-s>', require('snip').pick)
```

## Configuration

Whilst it's not required to use the plugin, there is a `setup` function which
allows overriding the default configuration:

```lua
require('snip').setup({
  -- Tell the plugin where to look for snippets
  snippets_dir = '/home/user/.shared-snippets',
  -- Alias filetypes to other file types to reuse snippets
  ft_map = {
    ['javascriptreact'] = 'typescriptreact',
  },
  -- Change the default name for the global snippets directory
  global_dirname = '_all',
})
```

## Completion plugins

### `blink.cmp`

To configure snippets with `blink.cmp`, add the following to your blink setup:

```lua
require('blink.cmp').setup({
  -- ...
  sources = {
    default = { 'snip' },
    providers = {
      snip = {
        name = 'snip',
        module = 'snip.blink',
      },
    },
  },
})
```
