# Author: Andrey Listopadov
# Module for opening files with fzf for fzf.kak plugin
# https://github.com/andreyorst/fzf.kak

hook global ModuleLoaded fzf %{
    map global fzf -docstring "open file" 'f' '<esc>: require-module fzf-file; fzf-file<ret>'
    map global fzf -docstring "open file in dir of currently displayed file" 'F' '<esc>: require-module fzf-file; fzf-file buffile-dir<ret>'
}

provide-module fzf-file %§

declare-option -docstring "command to provide list of files to fzf
ex:
    find: ""find -L . -type f""
    ag:   ""ag -l -f --hidden --one-device .""
    rg:   ""rg -L --hidden --files""
    fd:   ""fd --type f --follow""
" \
str fzf_file_command "find -L . -type f"

define-command -hidden fzf-file -params 0..2 %{ evaluate-commands %sh{
    # Default fzf-file behavior
    search_dir="."
    if [ "$1" = "buffile-dir" ] || [ "$2" = "buffile-dir" ]; then
        # If the buffile-dir functionality (which is currently mapped to <fzf-mode> F) is
        # invoked by mistake on a buffile like `*scratch*` or `*grep*` and similar, there will be
        # no slashes in the buffile name and `dirname` will return `.` which means the functionality
        # will revert to the normal fzf-file behavior -- which is what we want in this scenario.
        search_dir=$(dirname "$kak_buffile")
    fi

    cmd="cd $search_dir; $kak_opt_fzf_file_command 2>/dev/null"

    maybe_filter_param=""
    if [ "$search_dir" != "." ]; then
        # Since we cd-ed into search dir in $cmd, prefix the $search_dir path after fzf returns the results by using -filter switch of fzf.
        # Kakoune either needs an absolute path or path relative to its pwd to edit a file. Since the pwd of $cmd and kakoune now differ,
        # we cannot use a relative path, so we construct the absolute path by prefixing the $search_dir to the file outputted by fzf.
        maybe_filter_param=$(printf "%s %s" "-filter" "%{perl -pe \"print \\\"$search_dir/\\\"\"}")
    fi

    message="<ret>: open file in new buffer."

    printf "%s\n" "info -title 'fzf file' '$message'"
    printf "%s\n" "fzf -preview $maybe_filter_param -kak-cmd %{edit -existing} -items-cmd %{$cmd}"
}}

§
