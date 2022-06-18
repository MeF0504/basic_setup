"vim script encording setting
scriptencoding utf-8

function! s:marp_template()
    " {{{
    append
---
marp: true
theme: gaia
---
<!-- paginate: true -->
<!-- size: 4:3 -->
---
<!-- _class: lead -->
# Title
### 20xx/xx/xx
### first_name last_name

---
## title 1

- aaa
- bbb
.
    " }}}
endfunction
command! -buffer MarpTemplate call s:marp_template()

highlight markdownItalic cterm=None gui=NONE

