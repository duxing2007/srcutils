"
" Execute global and load the result into quickfix window.
"
function! s:ExecLoad(option, long_option, pattern)
    " Execute global(1) command and write the result to a temporary file.
    let isfile = 0
    let option = ''
    let result = ''

    if a:option =~ 'f'
        let isfile = 1
        if filereadable(a:pattern) == 0
            call s:Error('File ' . a:pattern . ' not found.')
            return
        endif
    endif
    if a:long_option != ''
        let option = a:long_option . ' '
    endif
    let option = option . '-qx' . s:TrimOption(a:option)
    if isfile == 1
        let cmd = 'global ' . option . ' ' . a:pattern
    else
        let cmd = 'global ' . option . 'e ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char 
    endif

    let result = system(cmd)
    if v:shell_error != 0
        if v:shell_error != 0
            if v:shell_error == 2
                call s:Error('invalid arguments. (gtags.vim requires GLOBAL 5.7 or later)')
            elseif v:shell_error == 3
                call s:Error('GTAGS not found.')
            else
                call s:Error('global command failed. command line: ' . cmd)
            endif
        endif
        return
    endif
    if result == '' 
        if option =~ 'f'
            call s:Error('Tag not found in ' . a:pattern . '.')
        elseif option =~ 'P'
            call s:Error('Path which matches to ' . a:pattern . ' not found.')
        elseif option =~ 'g'
            call s:Error('Line which matches to ' . a:pattern . ' not found.')
        else
            call s:Error('Tag which matches to ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char . ' not found.')
        endif
        return
    endif

    " Open the quickfix window
    if g:Gtags_OpenQuickfixWindow == 1
"        topleft vertical copen
        botright copen
    endif
    " Parse the output of 'global -x' and show in the quickfix window.
    let efm_org = &efm
    let &efm="%*\\S%*\\s%l%\\s%f%\\s%m"
    cexpr! result
    let &efm = efm_org
endfunction






