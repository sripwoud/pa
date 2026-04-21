Fork of [biox/pa](https://github.com/biox/pa) — a simple password manager.

## features

- encryption implemented using [age](https://age-encryption.org)
- automatic key generation
- automatic git tracking
- multiple identity/recipient support
- written in bash
- simple to extend
- pronounced "pah" — as in "papa"

## additional features

- OTP management (TOTP/HOTP via `oathtool`)
- OTP shortcuts (`pa oi`, `pa oc`, `pa ou`, `pa ov`)
- random password generation with clipboard support
- QR code display via `qrencode`
- YubiKey identity support via `age-plugin-yubikey`
- [`pa-completion.bash`](./pa-completion.bash) — bash completions
- [`pa-dmenu`](./pa-dmenu) — dmenu integration
- [`pa-pass`](./pa-pass) — migration from [pass](https://www.passwordstore.org/)

## usage

```
pa
  a simple password manager

commands:
  [a]dd  [name]             - Add a password entry.
  [d]el  [name]             - Delete a password entry.
  [e]dit [name]             - Edit a password entry with vi.
  [g]it  [cmd]              - Run git command in the password dir.
  [l]ist [category]         - List all entries (or those in a category).
  [m]ove [src] [name]       - Rename a password entry.
  [s]how [name]             - Show password for an entry.
  [r]and [length] [pattern] - Generate a random password.
  [q]r [name]               - Show password as QR code.

otp commands:
  [o]tp [i]nsert [name]     - Add an OTP entry (reads URI from stdin).
  [o]tp [c]ode   [name]     - Generate a one-time code.
  [o]tp [u]ri    [name]     - Show the stored OTP URI.
  [o]tp [v]alidate [uri]    - Validate an OTP URI.

otp shortcuts:
  oi [name]                 - Same as otp insert.
  oc [name]                 - Same as otp code.
  ou [name]                 - Same as otp uri.
  ov [uri]                  - Same as otp validate.

env vars:
  data directory:   export PA_DIR=~/.local/share/pa
  password length:  export PA_LENGTH=50
  password pattern: export PA_PATTERN=A-Za-z0-9-_
  disable tracking: export PA_NOGIT=
```
