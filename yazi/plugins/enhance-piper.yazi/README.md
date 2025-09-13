# enhance-piper.yazi

`Piper.yazi` is a plugin that runs any shell command as a previewer.
And this `enhance-piper.yazi` is a wrapper that caches `Piper` command outputs in RAM for better performance.
When scrolling or re-rendering the previewer, the shell command will not run again.

## Installation

> [!IMPORTANT]
>
> - Minimum version: yazi v25.5.31.
> - Requires piper.yazi.

```sh
ya pkg add yazi-rs/plugins:piper
ya pkg add boydaihungst/enhance-piper
```

## Usage

Enhance-piper is a wrapper for piper.yazi previewer - you can pass any shell command to `enhance-piper` and it will use the command's output as the preview content, and the output of the command will be cached in ram for faster previewer scrolling or re-render previewer.

It accepts a string parameter, which is the shell command to be executed, for example:

> [!IMPORTANT]
> For yazi nightly, replace `name` with `url`

```toml
# ~/.config/yazi/yazi.toml
[[plugin.prepend_previewers]]
name = "*"
run  = 'enhance-piper -- echo "$1"'
```

This will set `enhance-piper` as the previewer for all file types and use enhance `$1` (file path) as the preview content.

## Variables

Available variables for command behind `--`:

- `$w`: the width of the preview area.
- `$h`: the height of the preview area.
- `$1`: the path to the file being previewed.

Available arguments for `enhance-piper` command itself:

- `--cache-limit=N`: the maximum number of cached command's output, default is N=100 entries.
- `--cache-max-lines=N`: Only cache if number of command's output is less than N, default is N=100000 lines.

## Examples

Here are some configuration examples:

> [!IMPORTANT]
> For yazi nightly, replace `name` with `url`

### Preview CSV with [`bat`](https://github.com/sharkdp/bat)

```toml
[[plugin.prepend_previewers]]
name = "*.csv"
run  = 'enhance-piper -- bat -p --color=always "$1"'
```

Note that certain distributions might use a different name for `bat`, like Debian and Ubuntu uses `batcat` instead, so please adjust accordingly.

### Preview Markdown with [`glow`](https://github.com/charmbracelet/glow)

```toml
[[plugin.prepend_previewers]]
name = "*.md"
run  = 'enhance-piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'
# OR with 1000 entries cache limit, and only cache file if number of lines is less than 10000
run  = 'enhance-piper --cache-max-lines=10000 --cache-limit=1000 -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'

```

you can also use `mime = "text/markdown"` instead of `name = "*.md"`

Note that there's [a bug in Glow v2.0](https://github.com/charmbracelet/glow/issues/440#issuecomment-2307992634) that causes slight color differences between tty and non-tty environments.

### Preview torrent with transmission-show and then highlight url with [`glow`](https://github.com/charmbracelet/glow)

```toml
[[plugin.prepend_previewers]]
mime = "application/bittorrent"
run  = 'enhance-piper -- transmission-show "$1" --no-header | CLICOLOR_FORCE=1 glow -w=$w -s=dark -'
```

Note that there's [a bug in Glow v2.0](https://github.com/charmbracelet/glow/issues/440#issuecomment-2307992634) that causes slight color differences between tty and non-tty environments.

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.
