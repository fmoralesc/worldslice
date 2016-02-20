# WORLDSLICE

A statusline configuration vim plugin.

## INTRO

A 4-dimensional world can be described as a sequence of 3-dimensional
slices, which are the state of the world at an index t.

This plugin is basically me extracting my statusline configuration into a
detachable module and working out some behavior kinks.

## USAGE

  Simply pass a list of items to *worldslice#init()*, like in the following
  example (it's a modification of my own config).

~~~ vim
    function! StatusDir()
	if &buftype != "nofile"
	    let d = expand("%:p:~:h")
	    if d != fnamemodify(getcwd(), ":~")
		return expand("%:p:.:h").'/'
	    else
		return ''
	    endif
	else
	    return ''
	endif
    endfunction

    let s:my_worldslice_config = [
		\ ['+(@:)'],
		\ ['%{fnamemodify(getcwd(), ":~")}', 'Special'],
		\ ['+(:)'],
		\ ['%n', 'Number'],
		\ ['+(:)'],
		\ ["%{expand('%:h')!=''?StatusDir():''}", 'Directory'],
		\ ["%{expand('%:h')!=''?expand('%:t'):'[unnamed]'}", 'Identifier'],
		\ ['%m%r', 'Boolean'],
		\ ['\ %=\'],
		\ ['%{&fenc}', 'Constant'],
		\ ['+(:)'],
		\ ['%{&ft}', 'Type'],
		\ ['+(:)'],
		\ ['%{&fo}', 'Function'],
		\ ['+(:)'],
		\ ["%{&spell?&spl:''}", 'SpellBad'],
		\ ['\ %l,%c', 'Number']
		\ ]
    call worldslice#init(s:my_worldslice_config)
~~~

The `+(...)` format is a shortcut for defining delimiters, the text between the
parentheses is displayed.
