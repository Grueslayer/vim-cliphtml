# vim-cliphtml

Copy the (visual selected) color rendered text from a VIM buffer to the system clipboard.

## Prerequisites

This plugin uses the default installed script 'syntax/2html.vim' (see `:help :TOhtml`) to convert the content to HTML.

For Windows systems you additionally need a python installation accessible from VIM (see `:help python`).

For Un*x like systems the application `xclip` will be used by default to copy the content to the system clipboard.

MacOS X already comes with the needed tools (`textutil` and `pbcopy`).

## Installing

Install using your favorite (or the build-in) plugin manager, e.g.

### vim-plug

Add the following configuration to your `.vimrc`

```vim
Plug 'grueslayer/vim-cliphtml'
```

and install with :PlugInstall.

### lazy.nvim

```lua
  { "grueslayer/vim-cliphtml" }
```

## Configuration

### g:cliphtml_toclipboard_cmd

This command will be used to write the content of the converted HTML buffer to the system clipboard.

The following defaults are used:

- Win32: Empty (Python is used)
- MacOS: `write !textutil -stdin -stdout -format html -convert rtf | pbcopy`
- Un*x: `write !xclip -t text/html -selection clipboard`

### g:cliphtml_tohtml_options

Contains a hash array of global variables to change the behaviour of :TOhtml (see `:help :TOhtml`) explicit for this function.
The previous values will be restored after creating the content.

Example:

```vim
let g:cliphtml_tohtml_options = {
    \ 'g:html_ignore_folding' : 1,
    \ 'g:html_number_lines' : 1,
    \ 'g:html_font' : ['consolas','verdana']
        \ }
```

### g:cliphtml_tohtml_pre / g:cliphtml_tohtml_post

As `:TOhtml` is completely rewritten in *neovim*, all `g:html_*` options are removed and display is rendered as given for the local buffer two new callback functions are added.

The options / plugins can be disabled by code, current values saved in a hash table and reset after the html code was created.

```lua
  {
    "grueslayer/vim-cliphtml",
    config = function()
      vim.g.cliphtml_tohtml_pre = function(savedvars)
        require "ibl".setup_buffer(vim.fn.bufnr(), { enabled = false })
        savedvars.list = vim.opt_local.list
        vim.opt_local.list = false
      end
      vim.g.cliphtml_tohtml_post = function(savedvars)
        require "ibl".setup_buffer(vim.fn.bufnr(), { enabled = true })
        vim.opt_local.list = savedvars.list
      end
    end
  },
```

## Built With

- [HtmlClipboard.py](https://gist.github.com/Erreinion/6691093) - Python code to access Win32 clipboard. Revised version of Phillip Piper's original [post](http://code.activestate.com/recipes/474121).

## Authors

- **Scott Graham** - *Initial work* - [ClipHtml](https://github.com/sgraham/sgraham/blob/master/vimfiles/plugin/cliphtml.vim)

See also the list of [contributors](https://github.com/grueslayer/vim-cliphtml/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
