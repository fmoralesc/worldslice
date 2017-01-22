# WORLDSLICE

A minimalistic statusline and tabline configuration vim plugin.

## INTRO

> A 4-dimensional world can be described as a sequence of 3-dimensional
slices, which are the state of the world at an index t.

This plugin is basically me extracting my statusline configuration into a
detachable module and working out some behavior kinks.

## USAGE

Simply create a list of items as `g:worldslice#config` and call
`worldslice#init()`, like in the following example (it's a modification of my
own config).

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

let g:worldslice#config = [
	    \ '+(@:)', ["%{fnamemodify(getcwd(),':~')}", 'Special'],
	    \ '+(:)', ['%n', 'Number'],
	    \ '+(:)', ["%{expand('%:h')!=''? StatusDir(): ''}", 'Directory'],
	    \ ["%{expand('%:h')!=''? expand('%:t'): '[unnamed]'}", 'Identifier'],
	    \ ['%m%r', 'Boolean'],
	    \ ' %=\',
	    \ ['%{&fenc}', 'Constant'],
	    \ '+(:)', ['%{&ft}', 'Type'],
	    \ '+(:)', ['%{&fo}', 'Function'],
	    \ '+(:)', ["%{&spell?&spl:''}", 'SpellBad'],
	    \ [' %l,%c', 'Number']
	    \ ]
call worldslice#init()
~~~

The `+(...)` format is a shortcut for defining delimiters, the text between the
parentheses is displayed.

You can also create a list and pass it as an argument to `worldslice#init()`
like in

~~~ vim
let my_config = [...]
call worldslice#init(my_config)
~~~

### Tabline and Sigils

If you are like me, you probably never use vim tabs, relying either on multiple
vim instances or on finder mechanisms. If this is the case, the tabline could,
and maybe *should* be (ab)used for different purposes. `worldslice` treats it
as a marquee for flags, which I like to call *sigils*. Basically, `worldslice`
keeps a dictionary of sigilss and watches for changes to it using the
dictionary watcher feature in nvim. Adding a new sigil is easy:

``` vim
let g:worldslice#sigils.my_sigil = 'x'
```

(updating them works the same), and so is removing them:

``` vim
call remove(g:worldslice#sigils, 'my_sigil')
```

Sigils always restore the tabline background color, so to colorize one you can
simply specify the highlighting group

``` vim
let g:worldslice#sigils.my_sigil = '%#SLBool#x'

```
