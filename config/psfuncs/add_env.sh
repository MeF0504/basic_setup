add_env()
{
    local echo_usage="
    usage: add_env [-h] [-dv] dir

    add dir/*/bin to PATH
    add dir/*/lib and dir/*/lib64 to LIBRARY_PATH & LD_LIBRARY_PATH
    add dir/*/share/man to MANPATH
    ignore directories starts with '_'

    positional arguments:
        dir    : path to the target directory

    optional arguments:
        -h, --help   show this help message and exit
        -d           also add dir/*/lib and dir/*/lib64 to DYLD_LIBRARY_PATH
        -v           show the verbose.
    "

    local dyn=0
    local verbose=0
    local in_dir=''

    ## argument analysis https://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb
    # typeset -i tmpargc=0
    # typeset -a tmpargv=()
    # echo argv $argv
    # echo argc $argc
    # $argv is the default variable of zsh. don't use it as a local variable.

    if (( $# == 0 )); then
        echo "$echo_usage"
        return
    fi
    while (( $# > 0 ))
    do
        case $1 in
            -*)
                if [[ "$1" =~ 'h' ]]; then
                    echo "$echo_usage"
                    return
                fi
                if [[ "$1" =~ 'd' ]]; then
                    dyn=1
                fi
                if [[ "$1" =~ 'v' ]]; then
                    verbose=1
                fi
                shift
                ;;
            *)
                in_dir="$1"
                shift
                ;;
        esac
    done
    if [[ ${in_dir: -1:1} = '/' ]]; then
        # remove '/' at end
        in_dir=${in_dir%/}
    fi

    find "$in_dir" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) \
        | while read -r basedir
    do
        if [[ $verbose = 1 ]]; then echo "  @ $basedir"; fi
        local bname=
        bname="$(basename "$basedir")"
        if [ "${bname:0:1}" = "_" ]; then
            if [[ $verbose = 1 ]]; then echo 'skip'; fi
            continue
        fi
        ### bin
        if [[ -d "$basedir"/bin && ! $PATH =~ .*"$basedir"/bin:.* ]]; then
            export PATH=$basedir/bin:$PATH
            if [[ $verbose = 1 ]]; then echo "add $basedir/bin to PATH"; fi
        fi
        ### lib
        if [[ -d "$basedir"/lib && ! $LD_LIBRARY_PATH =~ .*"$basedir"/lib:.* ]]; then
            # LIBRARY_PATH is for build? LD_LIBRARY_PATH is for execute?
            export LIBRARY_PATH=$basedir/lib:$LIBRARY_PATH
            export LD_LIBRARY_PATH=$basedir/lib:$LD_LIBRARY_PATH
            if [[ $verbose = 1 ]]; then echo "add $basedir/lib to LIBRARY_PATH & LD_LIBRARY_PATH"; fi
        fi
        if [[ "$dyn" = "1" && -d "$basedir"/lib && ! $DYLD_LIBRARY_PATH =~ .*"$basedir"/lib:.* ]]; then
            export DYLD_LIBRARY_PATH=$basedir/lib:$DYLD_LIBRARY_PATH
            if [[ $verbose = 1 ]]; then echo "add $basedir/lib to DYLD_LIBRARY_PATH"; fi
        fi
        ### lib64
        if [[ -d "$basedir"/lib64 && ! $LD_LIBRARY_PATH =~ .*"$basedir"/lib64:.* ]]; then
            export LIBRARY_PATH=$basedir/lib64:$LIBRARY_PATH
            export LD_LIBRARY_PATH=$basedir/lib64:$LD_LIBRARY_PATH
            if [[ $verbose = 1 ]]; then echo "add $basedir/lib64 to LIBRARY_PATH & LD_LIBRARY_APTH"; fi
        fi
        if [[ "$dyn" = "1" && -d "$basedir"/lib64 && ! $DYLD_LIBRARY_PATH =~ .*"$basedir"/lib64:.* ]]; then
            export DYLD_LIBRARY_PATH=$basedir/lib64:$DYLD_LIBRARY_PATH
            if [[ $verbose = 1 ]]; then echo "add $basedir/lib64 to DYLD_LIBRARY_PATH"; fi
        fi
        ## man
        if [[ -d "$basedir"/share/man && ! $MANPATH =~ .*"$basedir"/share/man:.* ]]; then
            if [[ $verbose = 1 ]]; then echo "add $basedir/share/man to MANPATH"; fi
            export MANPATH=$basedir/share/man:$MANPATH
        fi
    done
}

