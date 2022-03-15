# Dependencies

- [Bitwarden CLI](https://github.com/bitwarden/cli)
- jq
- fzf
- Oh My Zsh (if `ZSH_BITWARDEN_COPY_CMD` is not set)

# Install (Antigen)

```zsh
# Requires oh-my-zsh unless ZSH_BITWARDEN_COPY_CMD is set
antigen use oh-my-zsh

antigen bundle kalsowerus/zsh-bitwarden
```

# Usage
Opens a fzf widget containing your Bitwarden vault items.
Upon selecting an item either the username or password will be either written into the shell or copied into the clipboard.

Shares the Bitwarden session across terminal sessions.

## Key bindings

| Keys | Action |
| ---- | ------ |
| <kbd>alt</kbd>+<kbd>U</kbd> | Get username |
| <kbd>alt</kbd>+<kbd>P</kbd> | Get password |
| <kbd>ctrl</kbd>+<kbd>U</kbd> | Copy username |
| <kbd>ctrl</kbd>+<kbd>P</kbd> | Copy password |

# Configuration

## `ZSH_BITWARDEN_COPY_CMD`

Contains the command used to copy a username/password to the clipboard.
The username/password will be piped to the command.

Default: `clipcopy`

## `ZSH_BITWARDEN_GET_USERNAME_KEY`

The key to "get" a username.

Default: `^[u` (<kbd>alt</kbd>+<kbd>U</kbd>)

## `ZSH_BITWARDEN_GET_PASSWORD_KEY`

The key to "get" a password.

Default: `^[p` (<kbd>alt</kbd>+<kbd>P</kbd>)

## `ZSH_BITWARDEN_COPY_USERNAME_KEY`

The key to copy a username to the clipboard.

Default `^U` (<kbd>ctrl</kbd>+<kbd>U</kbd>)

## `ZSH_BITWARDEN_COPY_PASSWORD_KEY`

The key to copy a password to the clipboard.

Default: `^P` (<kbd>ctrl</kbd>+<kbd>P</kbd>)

