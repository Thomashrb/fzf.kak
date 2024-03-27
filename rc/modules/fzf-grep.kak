# Author: Andrey Listopadov
# Module for grepping file contents
# https://github.com/andreyorst/fzf.kak

hook global ModuleLoaded fzf %{
    map -docstring 'grep file contents recursively' global fzf g ': require-module fzf-grep; fzf-grep<ret>'
}

provide-module fzf-grep %§

declare-option -docstring "What command to use to provide a list of grep search matches.
Grep output must follow the format of 'filename:line-number:text', and specify a pattern to match across all file contents.
By default, an empty pattern is searched, effectively matching every line in every file" \
str fzf_grep_command "rg --line-number --no-column --no-heading --color=never ''"

declare-option -docstring "Whether to enable preview in grep window" \
bool fzf_grep_preview true

declare-option -docstring "Preview command for seeing file contents of the selected item" \
str fzf_grep_preview_command 'bat --color=always --highlight-line {2} {1}'


define-command -hidden fzf-grep %{ evaluate-commands %sh{
    cmd="$kak_opt_fzf_grep_command 2>/dev/null"

    title="fzf grep"
    message="grep through contents of all files recursively.
<ret>: open search result in new buffer.
${kak_opt_fzf_window_map:-ctrl-w}: open search result in new terminal"
    [ -n "${kak_client_env_TMUX:-}" ] && tmux_keybindings="
${kak_opt_fzf_horizontal_map:-ctrl-s}: open search result in horizontal split
${kak_opt_fzf_vertical_map:-ctrl-v}: open search result in vertical split"

    preview_cmd=""
    if [ "${kak_opt_fzf_grep_preview:-}" = "true" ]; then
        preview_cmd="-preview -preview-cmd %{--preview '(${kak_opt_fzf_grep_preview_command} || cat {1}) 2>/dev/null' --preview-window=\${pos}:+{2}-/2}"
    fi

    printf "%s\n" "info -title '${title}' '${message}${tmux_keybindings}'"
    [ -n "${kak_client_env_TMUX}" ] && additional_flags="--expect ${kak_opt_fzf_vertical_map:-ctrl-v} --expect ${kak_opt_fzf_horizontal_map:-ctrl-s}"
    printf "%s\n" "fzf -kak-cmd %{evaluate-commands} ${preview_cmd} -fzf-args %{--expect ${kak_opt_fzf_window_map:-ctrl-w} $additional_flags  --delimiter=':' -n'3..'} -items-cmd %{$cmd} -filter %{sed -E 's/([^:]+):([^:]+):.*/edit -existing \1; execute-keys \2gvc/'}"
}}

§
