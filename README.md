<p align="center">Fork of <a href="https://github.com/biox/pa">biox/pa</a> — a simple password manager.</p>

## Features

- encryption implemented using [age](https://age-encryption.org)
- automatic key generation
- automatic git tracking
- multiple identity/recipient support
- written in bash
- simple to extend
- pronounced "pah" — as in "papa"

## Additional Features

- OTP management (TOTP/HOTP via `oathtool`)
- OTP shortcuts (`pa oi`, `pa oc`, `pa ou`, `pa ov`)
- random password generation with clipboard support
- QR code display via `qrencode`
- YubiKey identity support via `age-plugin-yubikey`
- [`completions/pa.bash`](./completions/pa.bash) — bash completions
- [`contrib/pa-dmenu`](./contrib/pa-dmenu) — dmenu integration
- [`contrib/pa-pass`](./contrib/pa-pass) — migration from [pass](https://www.passwordstore.org/)

## Usage

```
pa
  a simple password manager

commands:
  a|add  [name]             - Add a password entry.
  d|del  [name]             - Delete a password entry.
  e|edit [name]             - Edit a password entry with vi.
  g|git  [cmd]              - Run git command in the password dir.
  l|list [category]         - List all entries (or those in a category).
  m|move [src] [name]       - Rename a password entry.
  s|show [name]             - Show password for an entry.
  r|rand [length] [pattern] - Generate a random password.
  q|qr   [name]             - Show password as QR code.
  me|meta [name]            - Add a metadata entry (name/meta).

otp commands:
  o|otp i|insert [name]     - Add an OTP entry (reads URI from stdin).
  o|otp c|code   [name]     - Generate a one-time code.
  o|otp u|uri    [name]     - Show the stored OTP URI.
  o|otp v|validate [uri]    - Validate an OTP URI.

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
