" Author: Devon Meunier <devon.meunier@gmail.com>
" Description: checkstyle for Apex files

call ale#Set('apex_checkstyle_executable', 'checkstyle')
call ale#Set('apex_checkstyle_config', '/google_checks.xml')
call ale#Set('apex_checkstyle_options', '')

function! ale_linters#apex#checkstyle#Handle(buffer, lines) abort
    let l:output = []

    " modern checkstyle versions
    let l:pattern = '\v\[(WARN|ERROR)\] [a-zA-Z]?:?[^:]+:(\d+):(\d+)?:? (.*) \[(.+)\]$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': l:match[1] is? 'WARN' ? 'W' : 'E',
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4],
        \   'code': l:match[5],
        \})
    endfor

    if !empty(l:output)
        return l:output
    endif

    " old checkstyle versions
    let l:pattern = '\v(.+):(\d+): ([^:]+): (.+)$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': l:match[3] is? 'warning' ? 'W' : 'E',
        \   'lnum': l:match[2] + 0,
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

function! s:GetConfig(buffer, config) abort
    if ale#path#IsAbsolute(a:config)
        return a:config
    endif

    let s:file = ale#path#FindNearestFile(a:buffer, a:config)

    return !empty(s:file) ? s:file : a:config
endfunction

function! ale_linters#apex#checkstyle#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'apex_checkstyle_options')
    let l:config_option = ale#Var(a:buffer, 'apex_checkstyle_config')
    let l:config = l:options !~# '\v(^| )-c' && !empty(l:config_option)
    \   ? s:GetConfig(a:buffer, l:config_option)
    \   : ''

    return '%e'
    \ . ale#Pad(l:options)
    \ . (!empty(l:config) ? ' -c ' . ale#Escape(l:config) : '')
    \ . ' %s'
endfunction

call ale#linter#Define('apex', {
\   'name': 'checkstyle',
\   'executable': {b -> ale#Var(b, 'apex_checkstyle_executable')},
\   'command': function('ale_linters#apex#checkstyle#GetCommand'),
\   'callback': 'ale_linters#apex#checkstyle#Handle',
\   'lint_file': 1,
\})
