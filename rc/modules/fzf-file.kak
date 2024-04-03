# Author: Andrey Listopadov
# Module for opening files with fzf for fzf.kak plugin
# https://github.com/andreyorst/fzf.kak

hook global ModuleLoaded fzf %{
    map global fzf -docstring "open file" 'f' '<esc>: require-module fzf-file; fzf-file<ret>'
    map global fzf -docstring "open file in dir of currently displayed file" 'F' '<esc>: require-module fzf-file; fzf-file buffile-dir<ret>'
}

provide-module fzf-file %§

declare-option -docstring "command to provide list of files to fzf. Arguments are supported
Supported tools:
    <package>:           <value>:
    GNU Find:            ""find""
    The Silver Searcher: ""ag""
    ripgrep:             ""rg""
    fd:                  ""fd""

Default arguments:
    find: ""find -L . -type f""
    ag:   ""ag -l -f --hidden --one-device .""
    rg:   ""rg -L --hidden --files""
    fd:   ""fd --type f --follow""
" \
str fzf_file_command "find"

declare-option -docstring 'allow showing preview window while searching for file
Default value:
    true
' \
bool fzf_file_preview true


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

    if [ -z "$(command -v "${kak_opt_fzf_file_command%% *}")" ]; then
        printf "%s\n" "echo -markup '{Information}''$kak_opt_fzf_file_command'' is not installed. Falling back to ''find'''"
        kak_opt_fzf_file_command="find"
    fi
    cmd_append=""
    case "$1" in
       (extra-switch=*) cmd_append="${1#extra-switch=}" ;;
    esac
    case "$2" in
       (extra-switch=*) cmd_append="${2#extra-switch=}" ;;
    esac
    case $kak_opt_fzf_file_command in
        (find)              cmd="find -L . -type f $cmd_append" ;;
        (ag)                cmd="ag -l -f --hidden --one-device $cmd_append . " ;;
        (rg)                cmd="rg -L --hidden --files $cmd_append" ;;
        (fd)                cmd="fd --type f --follow $cmd_append" ;;
        (find*|ag*|rg*|fd*) cmd="$kak_opt_fzf_file_command $cmd_append";;
        (*)                 items_executable=$(printf "%s\n" "$kak_opt_fzf_file_command $cmd_append" | grep -o -E "[[:alpha:]]+" | head -1)
                            printf "%s\n" "echo -markup %{{Information}Warning: '$items_executable' is not supported by fzf.kak.}"
                            cmd="$kak_opt_fzf_file_command $cmd_append";;
    esac

    cmd="cd $search_dir; $cmd 2>/dev/null"
    message="<ret>: open file in new buffer."

    printf "%s\n" "info -title 'fzf file' '$message$tmux_keybindings'"
    [ "${kak_opt_fzf_file_preview:-}" = "true" ] && preview_flag="-preview"
    printf "%s\n" "fzf $preview_flag $search_dir -kak-cmd %{edit -existing} -items-cmd %{$cmd} -fzf-args %{-m $additional_flags}"
}}

§
