" Author: Horacio Sanson https://github.com/hsanson
" Description: Functions for integrating with Java tools

" Find the nearest dir contining a gradle or pom file and asume it
" the root of a apex app.
function! ale#apex#FindProjectRoot(buffer) abort
    let l:sfdx_path = ale#path#FindNearestFile(a:buffer, 'sfdx-project.json')

    if !empty(l:sfdx_path)
        return fnamemodify(l:sfdx_path, ':h')
    endif

    return ''
endfunction
