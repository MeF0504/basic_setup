if &filetype == 'tex'
    call meflib#set('qrun_opt', 1)

    function! <SID>qrun_tex() abort
        " macOSでlatex (ptex2pdf)を使う場合
        " https://texwiki.texjp.org/?quickrun
        if isdirectory('/Applications/Skim.app')
            let open_tex_pdf = 'open -a Skim'
        else
            let open_tex_pdf = meflib#basic#get_exe_cmd()
            if empty(open_tex_pdf)
                echo 'failed to get exec command'
                return
            endif
        endif

        " get main & bib file
        let local_config = expand('%:h')..'/.tex_setting.txt'
        if filereadable(local_config)
            let [main_file, bib_file] = readfile(local_config)
        else
            let main_file = input('main file: ', expand('%:p'), 'file')
            let bib_file = input('main file: ', expand('%:p:h'), 'file')
            call writefile([main_file, bib_file], local_config)
        endif
        let main_file = fnamemodify(main_file, ':.')
        let bib_file = fnamemodify(bib_file, ':.')
        let pdf_file = fnamemodify(main_file, ':r').'.pdf'

        " texの中間ファイルはbuild dirに突っ込む
        let build_dir = fnamemodify(main_file, ':h').'/__build__'
        if !isdirectory(build_dir)
            call mkdir(build_dir, 'p')
        endif
        let build_pdf = build_dir.'/'.fnamemodify(pdf_file, ':t')

        " bibliography があり，かつ.bibがmain.texより新しければbibもコンパイル
        let cmp_bib = 0
        if !empty(bib_file)
            if getftime(main_file) < getftime(bib_file)
                let cmp_bib = 1
            endif
        endif
        let q_config = {
            \ 'command': 'ptex2pdf',
            \ 'exec'   : [],
            \ }
        if cmp_bib == 1
            let q_config['exec'] += [
                \ printf('uplatex -output-directory %s %s', build_dir, fnamemodify(main_file, ':r')),
                \ printf('upbibtex %s/%s', build_dir, fnamemodify(main_file, ':t:r')),
                \ printf('uplatex -output-directory %s %s', build_dir, fnamemodify(main_file, ':r')),
                \ ]
        endif
        let q_config['exec'] += [
            \ printf('%%c -l -u -ot "-synctex=1 -interaction=nonstopmode" %s -output-directory %s', main_file, build_dir),
            \ printf('mv %s %s', build_pdf, pdf_file),
            \ printf('echo "\\n move from %s to %s"', build_pdf, pdf_file),
            \ printf('%s %s', open_tex_pdf, pdf_file),
            \ ]

        call quickrun#run(q_config)
    endfunction

    call <SID>qrun_tex()
    call meflib#set('qrun_finished', 1)
else
    call meflib#set('qrun_finished', 0)
endif
