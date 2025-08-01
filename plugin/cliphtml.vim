"
" For pasting highlighted code from gvim into Outlook.
"
" Put this file in your 'plugin' directory.
"
" You need to have +python and the win32 extensions installed.
" On Vim72 this is a quite old python 2.4. On Windows for whatever
" reason, Vim loads python via dll, so you''ll actually have to
" install python2.4 and pywin32-2.4, even if :ver is +python/dyn.
"
"
" Uses 2html to convert to html (same as :TOhtml), some python to
" stuff on to the Windows clipboard as html.
"
" The user command is :ClipHtml, and it optionally accepts a range.
" (i.e. you can visual select a block). A large file will take
" a while, 2html is quite slow, but a selection is normally OK.
"
"
" Scott Graham <scott.cliphtml@h4ck3r.net>
"
"

if ((has('win32') || has('win64')) && (has('pythonx') || has('nvim')))
  let s:FuncBufferToHtmlClipboardWin32 = 1
  exec 'pyxfile '.fnamemodify(resolve(expand('<sfile>:p')), ':h').'/HtmlClipboard.py'
  function! s:BufferToHtmlClipboardWin32()
pythonx <<ENDOFPYTHON
import vim
str = '\n'.join(vim.current.buffer)
cb = HtmlClipboard()
cb.PutFragment(str)
ENDOFPYTHON
  endfunction
endif


function! s:ConvertAndClipAsHtml(line1, line2)

  let l:html_start_line = min([a:line1,a:line2])
  let l:html_end_line =  max([a:line1,a:line2])

  let l:savedVariables = {}
  let l:unsetVariables = []

  if exists('g:cliphtml_tohtml_options')
    let l:keys = keys(g:cliphtml_tohtml_options)
    for l:key in l:keys
      if exists(l:key)
        let l:savedVariables[l:key] = eval(l:key)
      else
        call add(l:unsetVariables, l:key)
      endif
      execute('let '.l:key.'='.string(g:cliphtml_tohtml_options[l:key]))
    endfor
  elseif exists('g:cliphtml_tohtml_pre')
    if type(g:cliphtml_tohtml_pre) == v:t_func
      call g:cliphtml_tohtml_pre(l:savedVariables)
    endif
  endif

  if !has('nvim')
    let g:html_start_line = l:html_start_line
    let g:html_end_line = l:html_end_line

    runtime syntax/2html.vim

    unlet g:html_start_line
    unlet g:html_end_line
  else
    execute(l:html_start_line .. ',' .. l:html_end_line .. 'TOhtml')
  endif

  if has('nvim')
    execute(':%s/\(^body \(.*\)\)\n/\1\rpre \2\r')
  endif

  if exists('g:cliphtml_toclipboard_cmd') && !empty(g:cliphtml_toclipboard_cmd)
    execute(g:cliphtml_toclipboard_cmd)
  elseif exists("s:FuncBufferToHtmlClipboardWin32")
    call <SID>BufferToHtmlClipboardWin32()
  elseif has('win32')
    write !powershell -NoProfile -NonInteractive -Command "Set-Clipboard $input"
  elseif has('mac')
    write !textutil -stdin -stdout -format html -convert rtf | pbcopy
  elseif executable('xclip')
    write !xclip -t text/html -selection clipboard
  else
    echoerr 'Clipboard application not found'
  endif

  bdelete!

  if exists('g:cliphtml_tohtml_options')
    let l:keys = keys(l:savedVariables)
    for l:key in l:keys
      execute('let '.l:key.'='.string(l:savedVariables[l:key]))
    endfor
    for l:key in l:unsetVariables
      execute('unlet '.l:key)
    endfor
  elseif exists('g:cliphtml_tohtml_post')
    if type(g:cliphtml_tohtml_post) == v:t_func
      call g:cliphtml_tohtml_post(l:savedVariables)
    endif
  endif
endfunc

command! -range=% ClipHtml :call <SID>ConvertAndClipAsHtml(<line1>, <line2>)
