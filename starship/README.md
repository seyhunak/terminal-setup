# starship/

`starship.toml` is the **old hand-rolled prompt** (catppuccin-powerline style),
kept for reference only. Nothing in `install.sh` links or reads it.

The active prompt is managed by [stellar](https://stellar.a3chron.dev):

```sh
stellar apply a3chron/ctp-blue
```

which writes `~/.config/starship.toml` as a symlink into
`~/.config/stellar/a3chron/ctp-blue/<version>.toml`.

To go back to the archived config:

```sh
stellar apply seyhunakyurek/backup@1.0
# or, bypassing stellar entirely:
ln -sf "$PWD/starship/starship.toml" ~/.config/starship.toml
```

Note that `mise` / `direnv` / `docker` segments present in this archived file
are not part of the upstream `ctp-blue` theme, so they will not reappear unless
you keep using this file.
