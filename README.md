# qcd

`qcd` means **quick cd** (quick change directory).

It is a small zsh bookmark manager for directories.

## Features

- `qcd add`: add a directory bookmark
- `qcd <alias>`: jump to a saved directory
- `qcd list`: list all bookmarks in aligned columns
- `qcd remove <alias>`: remove a bookmark
- `qcd help`: show usage
- Persistent storage in `~/.qcd_bookmarks.zsh`

## Requirements

- `zsh`
- macOS/Linux shell environment

## Install

### Homebrew (recommended)

```zsh
brew tap adamzafir/qcd https://github.com/adamzafir/qcd
brew install qcd
echo 'source "$(brew --prefix)/share/qcd/qcd.zsh"' >> ~/.zshrc
source ~/.zshrc
```

### Manual

```zsh
git clone https://github.com/adamzafir/qcd.git ~/.qcd
echo 'source ~/.qcd/qcd.zsh' >> ~/.zshrc
source ~/.zshrc
```

## Usage

### Add a bookmark

```zsh
qcd add
# add the path: ~/Desktop/Programming
# add the alias: prog
```

### Jump to a bookmark

```zsh
qcd prog
```

### List bookmarks

```zsh
qcd list
```

### Remove a bookmark

```zsh
qcd remove prog
```

### Help

```zsh
qcd help
```

## Notes

- Alias format is validated as: `[A-Za-z0-9._-]+`
- Relative paths and `~` are expanded to absolute paths
- If an alias already exists, `qcd add` overwrites it
- Legacy malformed aliases (from older buggy versions) are normalized automatically when loaded

## Storage

By default bookmarks are stored in:

```text
~/.qcd_bookmarks.zsh
```

You can override this location:

```zsh
export QCD_STORE="$HOME/.my_qcd_bookmarks.zsh"
```

## Uninstall

1. Remove the source line from `~/.zshrc`
2. Delete the repo folder
3. Optionally remove `~/.qcd_bookmarks.zsh`

## License

MIT
