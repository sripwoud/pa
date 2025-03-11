Collection of scripts to manage passwords and 2FA with [age](https://age-encryption.org) encryption.

- [`pa`](./pa) is the password manager ([passwordass](https://passwordass.org) from [biox/pa](https://github.com/biox/pa)).
  - [`pa-dmenu`](./pa-dmenu) integrates `pa` with [dmenu](https://tools.suckless.org/dmenu/).
  - [`pa-pass`](./pa-pass) migrates passwords from [`pass`](https://www.passwordstore.org/) to `pa`.
  - [`_pa`](./_pa) are my zsh completions for `pa`.
- [`paotp`](./paotp) manages OTPs with `pa` (my modified version of [pass-otp](https://github.com/tadfisher/pass-otp) that uses `pa` for password storage).
- [`otp`](./otp) integrates `paotp` with [`dmenu`](https://tools.suckless.org/dmenu/) and [`zbar`](https://github.com/mchehab/zbar) (my modified version of [lukesmithxyz voidrive otp](https://github.com/LukeSmithxyz/voidrice/blob/master/.local/bin/otp) that uses `paotp` for OTP storage).
