# compress.yazi

<!--toc:start-->

- [compress.yazi](#compressyazi)
  - [Supported file types](#supported-file-types)
  - [New features of this fork](#new-features-of-this-fork)
  - [Install](#install)
  - [Usage](#usage)
  <!--toc:end-->

A Yazi plugin that compresses selected files to an archive. Supporting yazi versions 25.5.31 and up.

## Supported file types

| Extention | Unix Command    | Windows Command |
| --------- | --------------- | --------------- |
| .zip      | 7z a -tzip      | 7z a -tzip      |
| .7z       | 7z a            | 7z a            |
| .rar      | rar (not unrar) | rar             |
| .tar      | tar rpf         | tar rpf         |
| .tar.gz   | gzip            | 7z a -tgzip     |
| .tar.xz   | xz              | 7z a -txz       |
| .tar.bz2  | bzip2           | 7z a -tbzip2    |
| .tar.lz4  | lz4             | lz4             |
| .tar.zst  | zstd            | zstd            |

**NOTE:** Windows users are required to install 7-Zip and add 7z.exe to the `path` environment variable, only tar archives will be available otherwise.

## New features of this fork

- Support for `lha`, `lz4` and `rar` archives
- Support input password to encrypt archives

## Install

```bash
# with yazi plugin manager
ya pkg add boydaihungst/compress
# or
ya pack -a boydaihungst/compress
```

- Add this to your `keymap.toml`:
- Check default keymaps to prevent conflict https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/keymap-default.toml

```toml
[manager]
  prepend_keymap = [
    { on = [ "e", "c" ], run = "plugin compress", desc = "Compress file(s)" },
    # If you input empty password, it will make an archive without password
    { on = [ "e", "C" ], run = "plugin compress -- --secure", desc = "Compress file(s) with password" },
  ]
```

## Usage

- Select files or folders or hover over a file, then press `e` `c` or `e` `C` to create a new archive.
- Type a name for the new file and password (Optional).
- The file extention must match one of the supported filetype extentions.
- The desired archive/compression command must be installed on your system.
