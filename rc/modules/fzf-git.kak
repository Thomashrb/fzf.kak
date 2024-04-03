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
    message="<ret>: open file in new buffer."
    printf "%s\n" "fzf -kak-cmd %{edit -existing} -items-cmd %{$kak_opt_fzf_git_command} -fzf-args %{-m $additional_flags}"
}}

§
