"unlet s:slice_highlights
let s:slice_highlights = [
	    \ 'Special', 
	    \ 'Delimiter', 
	    \ 'Number',
	    \ 'Boolean',
	    \ 'Directory', 
	    \ 'Identifier', 
	    \ 'Character',
	    \ 'Constant',
	    \ 'Type',
	    \ 'Function',
	    \ 'SpellBad' ]

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
    hi! StatusLine guibg=#151515 guifg=#ffffff gui=None cterm=None ctermbg=233 ctermfg=15
    let l:sl_highlight = s:get_highlight_dict('StatusLine')
    if $NVIM_TUI_ENABLE_TRUE_COLOR != 1
	let l:bg_key = 'ctermbg'
	let l:fg_key = 'ctermfg'
	let l:mod_key = 'cterm'
    elseif $NVIM_TUI_ENABLE_TRUE_COLOR == 1 || has('gui_running') == 1
	let l:bg_key = 'guibg'
	let l:fg_key = 'guifg'
	let l:mod_key = 'gui'
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
endfunction

let s:statusline=''

function! s:litemize(item)
    if type(a:item) == type('')
	return [a:item]
    else
	return a:item
    endif
endfunction

" \ 
function! s:escape(str)
    return substitute(a:str, '\\\@<! ', '\\ ', 'g')
endfunction

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
    endif
    call worldslice#build_statusline(l:config)
    call worldslice#apply_statusline()
    call worldslice#compute_highlights()
    au! ColorScheme * call worldslice#compute_highlights()
    au! BufEnter * call worldslice#apply_statusline()
    au! BufLeave * call worldslice#unfocus()
endfunction
