# fzf.kak

This is a fork of fzf.kak attempting to slim down the supported featureset with the goal of being easier to keep up to date.
fzf.kak is a plugin for [Kakoune][7] editor, that provides integration with the [fzf][8] tool.

## Installation

This plugin consists of several parts which are referred to as "modules".
So, for the plugin to work the base module must be loaded:

``` sh
source "/path/to/fzf.kak/rc/fzf.kak" # loading base fzf module
```

This module doesn't do anything on its own.
Each module in the `modules` directory provides features that extend the base `fzf` module with new commands and mappings.
Those can be loaded manually one by one the same way as the base module, or with the use of the `find` command:

``` sh
evaluate-commands %sh{
    find -L "path/to/fzf.kak/modules/" -type f -name '*.kak' -exec printf 'source "%s"\n' {} \;
}
```


## Usage

fzf.kak provides a `fzf-mode` command that can be mapped to preferred key:

```kak
map global normal <c-p> ': fzf-mode<ret>'
```

This will invoke the user mode, which contains mnemonic keybindings for each sub-module.
If all modules were loaded, the following mappings are available:

- <kbd>b</kbd> - Select buffer.
- <kbd>f</kbd> - Search for file and open it.
- <kbd>v</kbd> - Search for file in git/vcs project
- <kbd>s</kbd> - Search over buffer contents and jump to result line.
- <kbd>t</kbd> - Browse ctags tags.
- <kbd>Alt</kbd>+<kbd>t</kbd> - Select tag kind filter on per language basis.
- <kbd>g</kbd> - Interactive grep.

When Kakoune runs inside Tmux, fzf.kak will use the bottom split to display the `fzf` window.
Additional keybindings are also made available to open files in a vertical or horizontal split.
Otherwise, the `terminal` command is being used to create new windows.


## Configuration

fzf.kak features a lot of settings via options that can be altered to change how fzf.kak behaves.
Each `.kak` file provides a Kakoune module, so any settings which alter variable values should be wrapped in the `ModuleLoaded` hook.


### Default query

| module |
|--------|
| `fzf`  |

By default main selection is used as the default query for `fzf`, but only if the selection is more than 1 character long.
This can be disabled by setting `fzf_use_main_selection` to `false`.


### Windowing

| module |
|--------|
| `fzf`  |

When using Tmux fzf.kak automatically creates all needed Tmux splits and panes for you.
In other cases fzf.kak uses the `fzf_terminal_command` option to call the windowing command to create new windows.
By default it is set to use `terminal` alias: `terminal kak -c %val{session} -e "%arg{@}"`, but some terminals can provide other aliases or commands, like `terminal-tab` in Kitty.


### Mappings

| module |
|--------|
| `fzf`  |

Keys that are used in the `fzf` window can be configured with these options:

- `fzf_window_map` - mapping to perform an action in a new window,
- `fzf_vertical_map` - mapping to perform an action in new vertical split (Tmux),
- `fzf_horizontal_map` - mapping to perform an action in new horizontal split.

These options should be set to work with fzf `--expect` parameter, so check out fzf documentation on this.

### Tmux

| module |
|--------|
| `fzf`  |

When running inside Tmux, `fzf` will use bottom split.
The height of this split can be changed with the `fzf_tmux_height` option.
`fzf_tmux_height_file_preview` option is used to control the height of the split when file-preview is turned on.


## `fzf` command

`fzf` command can be used from prompt mode and for scripting.
The following arguments are supported:

- `-kak-cmd`: A Kakoune command that is applied to `fzf` resulting value, e.g. `edit -existing`, `change-directory`, e.t.c.
- `-multiple-cmd`: A Kakoune command that is applied when multiple items are selected to every item but the first one.
- `-items-cmd`: A command that is used as a pipe to provide a list of values to `fzf`.
  For example, if we want to pass a list of all files recursively in the current directory, we would use `-items-cmd %{find .}` which will be piped to the `fzf` tool.
- `-fzf-args`: Additional flags for `fzf` program.
- `-preview-cmd`: A preview command.
  Can be used to override default preview handling.
- `-preview`: If specified, the command will ask for a preview.
- `-filter`: A pipe which will be applied to the result provided by `fzf`.
  For example, if we are returning such line `3 hello, world!` from `fzf`, and we are interested only in the first field which is `3`, we can use `-filter %{cut -f 1}`.
  Basically, everything that `fzf` returns is piped to this filter command.
- `-post-action`: Extra commands that are performed after the `-kak-cmd` command.


### External modules

Support for [yank-ring.kak][25] was externalized to separate plugin [fzf-yank-ring.kak][24]


# Alternatives

There are another (often more simple and robust) plugins, which add support for integration with `fzf` or other fuzzy finders that you might be interested in:

1. [peneira][26] - a fuzzy finder implemented specifically for Kakoune.
2. [connect.kak][27] - a tool that allows you to connect Kakoune with various applications like `fzf` and more.
3. [kakoune.cr][28] - a similar tool to `connect.kak`, but written in the Crystal language.
   Also allows you to connect Kakoune to other applications, including `fzf`.


[7]: https://github.com/mawww/kakoune
[8]: https://github.com/junegunn/fzf
[10]: https://user-images.githubusercontent.com/19470159/46813471-6ee76800-cd7f-11e8-89aa-123b3a5f9f1b.gif
[24]: https://gitlab.com/losnappas/fzf-yank-ring.kak
[25]: https://github.com/alexherbo2/yank-ring.kak
[26]: https://github.com/gustavo-hms/peneira
[27]: https://github.com/kakounedotcom/connect.kak
[28]: https://github.com/alexherbo2/kakoune.cr
[29]: https://jeskin.net/blog/clp/

<!--  LocalWords:  Github Kakoune fzf kak config git ctags Tmux fd
      LocalWords:  ripgrep readme rc
 -->
