# Author: Andrey Listopadov
# Git support for fzf.kak
# https://github.com/andreyorst/fzf.kak

hook global ModuleLoaded fzf %§
    map global fzf -docstring "edit file from vcs repo"      'v'     '<esc>: require-module fzf-git; fzf-git<ret>'
§

provide-module fzf-git %§

declare-option -docstring "command to provide list of files in git tree to fzf" \
str fzf_git_command "git ls-tree --full-tree --name-only -r HEAD"

define-command -hidden fzf-git %{ evaluate-commands %sh{
   title="fzf git"
    [ -n "${kak_client_env_TMUX:-}" ] && additional_keybindings="
${kak_opt_fzf_horizontal_map:-ctrl-s}: open file in horizontal split
${kak_opt_fzf_vertical_map:-ctrl-v}: open file in vertical split"
    message="Open single or multiple files from git tree.
<ret>: open file in new buffer.
${kak_opt_fzf_window_map:-ctrl-w}: open file in new terminal $additional_keybindings"
    [ ! -z "${kak_client_env_TMUX}" ] && additional_flags="--expect ${kak_opt_fzf_vertical_map:-ctrl-v} --expect ${kak_opt_fzf_horizontal_map:-ctrl-s}"
    printf "%s\n" "fzf -kak-cmd %{edit -existing} -items-cmd %{$kak_opt_fzf_git_command} -fzf-args %{-m --expect ${kak_opt_fzf_window_map:-ctrl-w} $additional_flags} -filter %{perl -pe \"if (/${kak_opt_fzf_window_map:-ctrl-w}|${kak_opt_fzf_vertical_map:-ctrl-v}|${kak_opt_fzf_horizontal_map:-ctrl-s}|^$/) {} else {print \\\"$(git rev-parse --show-toplevel)/\\\"}\"}"
}}

§
