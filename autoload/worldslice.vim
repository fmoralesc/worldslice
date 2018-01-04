" vim: set fdm=marker :
" worldslice.vim
" statusline and tabline configuration
" + sigils

" Global: {{{1
let s:slice_highlights = [
	    \ 'Boolean',
	    \ 'Character',
	    \ 'Conditional',
	    \ 'Constant',
	    \ 'Define',
	    \ 'Delimiter',
	    \ 'DiffAdd',
	    \ 'DiffChange',
	    \ 'DiffDelete',
	    \ 'Directory',
	    \ 'Exception',
	    \ 'Float',
	    \ 'Function',
	    \ 'Identifier',
	    \ 'Include',
	    \ 'Keyword',
	    \ 'Label',
	    \ 'Macro',
	    \ 'NonText',
	    \ 'Number',
	    \ 'Operator',
	    \ 'Question',
	    \ 'Repeat',
	    \ 'Special',
	    \ 'SpecialChar',
	    \ 'SpellBad',
	    \ 'Statement',
	    \ 'String',
	    \ 'Tag',
	    \ 'Title',
	    \ 'Todo',
	    \ 'Type',
	    \ 'Underlined'
	    \]

let s:statusline=''

function! s:litemize(item)
    if type(a:item) == type('')
	return [a:item]
    else
	return a:item
    endif
endfunction

function! s:escape(str)
    return substitute(a:str, '\\\@<! ', '\\ ', 'g')
endfunction

" Highlights: {{{1
function! s:get_highlight_dict(name)
    redir! => l:sl_data_raw
	exe 'silent hi '. a:name
    redir END
    " first elements are invariably the group name and 'xxx'
    let l:sl_data = split(l:sl_data_raw)[2:]
    let l:sl_data_zip = map(l:sl_data, 'split(v:val, "=")')
    let l:sl_data_dict = {}
    for pair in l:sl_data_zip
	if len(pair) == 2
	    let l:sl_data_dict[pair[0]] = pair[1]
	elseif len(pair) == 1
	    let l:sl_data_dict[pair[0]] = ''
	endif
    endfor
    return sl_data_dict
endfunction

function! worldslice#compute_highlights()
    if &background == 'dark'
	hi! StatusLine guibg=#151515 guifg=#ffffff gui=None cterm=None ctermbg=233 ctermfg=15
	hi! TabLine guibg=#151515 guifg=#ffffff gui=None cterm=None ctermbg=233 ctermfg=15
    else
	hi! StatusLine guibg=#eeeeee guifg=#ffffff gui=None cterm=None ctermbg=233 ctermfg=15
	hi! TabLine guibg=#eeeeee guifg=#ffffff gui=None cterm=None ctermbg=233 ctermfg=15
    endif
    let l:sl_highlight = s:get_highlight_dict('StatusLine')
    if has('gui_running') || &termguicolors
	let l:bg_key = 'guibg'
	let l:fg_key = 'guifg'
	let l:mod_key = 'gui'
    else
	let l:bg_key = 'ctermbg'
	let l:fg_key = 'ctermfg'
	let l:mod_key = 'cterm'
    endif
    for group in s:slice_highlights
	let l:orig_group_highlight = s:get_highlight_dict(group)
	if has_key(l:orig_group_highlight, l:fg_key)
	    exe 'hi! SL'.group.' '.l:bg_key.'='.l:sl_highlight[l:bg_key].
				\' '.l:fg_key.'='.l:orig_group_highlight[l:fg_key]
	    if has_key(l:orig_group_highlight, l:mod_key)
		exe 'hi SL'.group.' '.l:mod_key.'='.l:orig_group_highlight[l:mod_key]
	    endif
	endif
    endfor
    hi! link SLVCS SLDirectory
    hi! link SLError Error
    hi! link TabLineFill TabLine
endfunction

" Tabline: {{{1

function! worldslice#add_sigils()
    let sigils = []
    if exists('g:worldslice#sigils')
	for sigil in keys(g:worldslice#sigils)
	    let inner = g:worldslice#sigils[sigil]
	    if type(inner) == type('')
		call add(sigils, inner.'%#TabLine#')
	    elseif type(inner) == type([])
		call add(sigils, '%#SL'.inner[1].'#'.inner[0].'%#TabLine#')
	    endif
	endfor
    endif
    return join(sigils, '')
endfunction

function! worldslice#tablabel(n)
    let buflist = tabpagebuflist(a:n)
    let otherbufs = len(buflist)
    let winnr = tabpagewinnr(a:n)
    if gettabvar(a:n, 'name') != ''
	let b = gettabvar(a:n, 'name')
	if otherbufs > 1
	    let otherbufs_lbl = '('.otherbufs.')'
	else
	    let otherbufs_lbl = ''
	endif
    else
	let b = bufname(buflist[winnr - 1]).' '
	if b == ' '
	    let b = '[unnamed] '
	endif
	if otherbufs > 1
	    let otherbufs_lbl = '(+'.otherbufs-1.')'
	else
	    let otherbufs_lbl = ''
	endif
    endif
    return b. otherbufs_lbl. ' '
endfunction

function! worldslice#tabline(...)
    let t = ''
    for i in range(tabpagenr('$'))
	if (i + 1) == tabpagenr()
	    let t .= '%#TabLineSel#'
	else
	    let t .= '%#Tabline#'
	endif
	let t .= '%' . (i+1) . 'T'
	let t .= '%{worldslice#tablabel('. (i+1).')}'
    endfor
    let t .=  '%T %='.worldslice#add_sigils()
    return t
endfunction

function! worldslice#build_tabline(...)
    set tabline=%!worldslice#tabline()
endfunction

" Statusline: {{{1

function! worldslice#build_statusline(config)
    let s:steps = []
    for step in map(a:config, 's:litemize(v:val)')
	if len(step) == 1
	    if step[0] =~ '^+(.*)'
		let delim = matchstr(step[0], '(\@<=.*)\@=')
		call extend(s:steps, ['%#SLDelimiter#'.delim])
	    else
		call extend(s:steps, [s:escape(step[0])])
	    endif
        else
	    call extend(s:steps, ['%#SL'.step[1].'#'.s:escape(step[0])])
	endif
    endfor
    let s:statusline = join(s:steps, '')
endfunction

function! worldslice#apply_statusline()
    if &buftype == ''
	exe 'setlocal statusline='.s:statusline
    endif
endfunction

function! worldslice#unfocus()
    if &buftype == ''
	setlocal statusline&
    endif
endfunction

" Init: {{{1

function! worldslice#init(...)
    if a:0 > 0
	let l:config = a:1
    else
	if exists("g:worldslice#config")
	    let l:config = g:worldslice#config
	else
	    echom "worldslice: no configuration given, will use default statusline"
	    return
	endif
    endi
    if !exists("g:worldslice#sigils")
	let g:worldslice#sigils = {}
    endif
    " statusline
    call worldslice#build_statusline(l:config)
    call worldslice#apply_statusline()
    call worldslice#compute_highlights()
    au! ColorScheme * call worldslice#compute_highlights()
    au! BufEnter * call worldslice#apply_statusline()
    au! BufLeave * call worldslice#unfocus()
    " tabline
    call worldslice#build_tabline()
    if exists('*dictwatcheradd')
	call dictwatcheradd(g:worldslice#sigils, '*', 'worldslice#build_tabline')
	call dictwatcheradd(t:, '*', 'worldslice#build_tabline')
    endif
endfunction
