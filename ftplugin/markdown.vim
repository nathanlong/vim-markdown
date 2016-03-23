" Vim filetype plugin
" Language:     Markdown
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=>\ %s
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^[-*+]\\s\\+

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp<"
endif

" Markdown Preview Command
" Ported from Nate Silva's solution
" https://gist.github.com/natesilva/960015
"
" Requires Markdown or another markdown compiler (discount, pandoc, etc) to be
" installed. To use your engine of choice change MARKDOWN_COMMAND to whatever
" you want.

function! s:PreviewMarkdown()
    " **************************************************************
    " Configurable settings

    let MARKDOWN_COMMAND = 'markdown'

    if has('win32')
        " note important extra pair of double-quotes
        let BROWSER_COMMAND = 'cmd.exe /c start ""'
    else
        let BROWSER_COMMAND = 'open'
    endif

    " End of configurable settings
    " **************************************************************

    silent update
    let output_name = tempname() . '.html'

    " Some Markdown implementations, especially the Python one,
    " work best with UTF-8. If our buffer is not in UTF-8, convert
    " it before running Markdown, then convert it back.
    let original_encoding = &fileencoding
    let original_bomb = &bomb
    if original_encoding != 'utf-8' || original_bomb == 1
        set nobomb
        set fileencoding=utf-8
        silent update
    endif

    " Write the HTML header. Do a CSS reset, followed by setting up
    let file_header = ['<html lang="en-US">', '<head>',
        \ '<meta charset="utf-8">',
        \ '<meta http-equiv="x-ua-compatible" content="ie=edge">',
        \ '<title>Markdown Preview</title>',
        \ '<meta name="viewport" content="width=device-width, initial-scale=1">',
        \ '<style>html { font-family: sans-serif; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; } body { margin: 0; } article, aside, details, figcaption, figure, footer, header, main, menu, nav, section, summary { display: block; } audio, canvas, progress, video { display: inline-block; } audio:not([controls]) { display: none; height: 0; } progress { vertical-align: baseline; } template, [hidden] { display: none; } a { background-color: transparent; } a:active, a:hover { outline-width: 0; } abbr[title] { border-bottom: none; text-decoration: underline; text-decoration: underline dotted; } b, strong { font-weight: inherit; } b, strong { font-weight: bolder; } dfn { font-style: italic; } h1 { font-size: 2em; margin: 0.67em 0; } mark { background-color: #ff0; color: #000; } small { font-size: 80%; } sub, sup { font-size: 75%; line-height: 0; position: relative; vertical-align: baseline; } sub { bottom: -0.25em; } sup { top: -0.5em; } code, kbd, pre, samp { font-family: monospace, monospace; font-size: 1em; } figure { margin: 1em 40px; } hr { box-sizing: content-box; height: 0; overflow: visible; } button, input, select, textarea { font: inherit; } optgroup { font-weight: bold; } button, input, select { overflow: visible; } button, input, select, textarea { margin: 0; } button, select { text-transform: none; } button, [type="button"], [type="reset"], [type="submit"] { cursor: pointer; } [disabled] { cursor: default; } button, html [type="button"], [type="reset"], [type="submit"] { -webkit-appearance: button; } button::-moz-focus-inner, input::-moz-focus-inner { border: 0; padding: 0; } button:-moz-focusring, input:-moz-focusring { outline: 1px dotted ButtonText; } fieldset { border: 1px solid #c0c0c0; margin: 0 2px; padding: 0.35em 0.625em 0.75em; }</style>',
        \ '<style>body { background: #ffffff; color: #333; font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; } .container { width: 45em; margin: 3em auto; } blockquote { font-style: italic; } pre { background: #e5e5e5; } hr { border: 0; height: 0; border-top: 1px solid rgba(0, 0, 0, 0.1); border-bottom: 1px solid rgba(255, 255, 255, 0.3); margin: 2em 0; } .print { width: 100%; margin: 0; font-size: 12px; color: #000; } .toggle { position: absolute; top: 1em; right: 1em; font-size: 12px; -webkit-user-select: none; -khtml-user-select: none; -moz-user-select: none; -ms-user-select: none; -o-user-select: none; user-select: none; } @media print { .toggle { display: none; } }</style>',
        \ '<script>document.addEventListener("DOMContentLoaded", function() { document.querySelector(".toggle").addEventListener("click", function(e) { [].map.call(document.querySelectorAll(".container"), function(el) { el.classList.toggle("print"); });});});</script>',
        \ '</head>', '<body>', '<div class="container"><button type="button" class="toggle">Format for Print</button>']
    call writefile(file_header, output_name)

    let md_command = '!' . MARKDOWN_COMMAND . ' "' . expand('%:p') . '" >> "' .
        \ output_name . '"'
    silent exec md_command

    if has('win32')
        let footer_name = tempname()
        call writefile(['</div></body></html>'], footer_name)
        silent exec '!type "' . footer_name . '" >> "' . output_name . '"'
        exec delete(footer_name)
    else
        silent exec '!echo "</div></body></html>" >> "' .
            \ output_name . '"'
    endif

    " If we changed the encoding, change it back.
    if original_encoding != 'utf-8' || original_bomb == 1
        if original_bomb == 1
            set bomb
        endif
        silent exec 'set fileencoding=' . original_encoding
        silent update
    endif

    silent exec '!' . BROWSER_COMMAND . ' "' . output_name . '"'

    exec input('Press ENTER to continue...')
    echo
    exec delete(output_name)
endfunction

command! PreviewMarkdown :call <sid>PreviewMarkdown()

" Check for mapping and set default
if !hasmapto(':PreviewMarkdown<CR>')
  map <leader>p :PreviewMarkdown<CR>
endif

" vim:set sw=2:
