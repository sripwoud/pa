#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
  export PA_DIR="$BATS_TEST_TMPDIR/pa"
  export PA_NOGIT=1
  PA="$BATS_TEST_DIRNAME/pa"
  "$PA" list >/dev/null 2>&1
}

# --- Flags ---

@test "no args prints usage" {
  run "$PA"
  [[ $status -eq 0 ]]
  [[ $output == *"a simple password manager"* ]]
}

@test "--help prints usage" {
  run "$PA" --help
  [[ $status -eq 0 ]]
  [[ $output == *"a simple password manager"* ]]
}

@test "-h prints usage" {
  run "$PA" -h
  [[ $status -eq 0 ]]
  [[ $output == *"a simple password manager"* ]]
}

@test "--version prints version" {
  run "$PA" --version
  [[ $status -eq 0 ]]
  [[ $output == "pa 0.1.0" ]]
}

# --- Store initialization ---

@test "list initializes identity and recipient files" {
  [[ -s "$PA_DIR/identities" ]]
  [[ -s "$PA_DIR/recipients" ]]
  [[ -d "$PA_DIR/passwords" ]]
}

# --- Add and Show ---

@test "add creates encrypted entry" {
  printf y | "$PA" add test 2>/dev/null
  [[ -f "$PA_DIR/passwords/test.age" ]]
}

@test "add creates nested entry with category" {
  printf y | "$PA" add nested/password 2>/dev/null
  [[ -f "$PA_DIR/passwords/nested/password.age" ]]
}

@test "add prints status to stderr" {
  local stderr
  stderr=$(printf y | "$PA" add myentry 2>&1 1>/dev/null)
  [[ $stderr == *"saved 'myentry' to the store."* ]]
}

@test "show retrieves stored password" {
  printf y | "$PA" add roundtrip 2>/dev/null
  run "$PA" show roundtrip
  [[ $status -eq 0 ]]
  [[ -n $output ]]
}

@test "insert stores password from stdin" {
  printf 's3cr3t' | "$PA" insert piped 2>/dev/null
  run "$PA" show piped
  [[ $status -eq 0 ]]
  [[ $output == "s3cr3t" ]]
}

@test "insert stores multiline input" {
  printf 'pw\nuser: me\n' | "$PA" i multi 2>/dev/null
  run "$PA" show multi
  [[ $output == $'pw\nuser: me' ]]
}

@test "insert rejects empty stdin" {
  run "$PA" insert empty </dev/null
  [[ $status -ne 0 ]]
  [[ $output == *"password can't be empty"* ]]
  [[ ! -f "$PA_DIR/passwords/empty.age" ]]
}

@test "insert fails fast when stdin is a terminal" {
  command -v script >/dev/null || skip "script not installed"
  run script -qec "'$PA' insert ttyentry" /dev/null </dev/null
  [[ $status -ne 0 ]]
  [[ $output == *"reads the password from stdin"* ]]
  [[ ! -f "$PA_DIR/passwords/ttyentry.age" ]]
}

@test "insert rejects existing entry" {
  printf a | "$PA" insert dup 2>/dev/null
  run "$PA" insert dup <<<b
  [[ $status -ne 0 ]]
  [[ $output == *"already exists"* ]]
}

# --- List ---

@test "list shows all entries sorted" {
  printf y | "$PA" add beta 2>/dev/null
  printf y | "$PA" add alpha 2>/dev/null
  run "$PA" list
  [[ ${lines[0]} == "alpha" ]]
  [[ ${lines[1]} == "beta" ]]
}

@test "list filters by category" {
  printf y | "$PA" add cat/entry1 2>/dev/null
  printf y | "$PA" add other 2>/dev/null
  run "$PA" list cat
  [[ $output == *"cat/entry1"* ]]
  [[ $output != *"other"* ]]
}

# --- Delete ---

@test "del removes entry" {
  printf y | "$PA" add todelete 2>/dev/null
  [[ -f "$PA_DIR/passwords/todelete.age" ]]
  printf y | "$PA" del todelete 2>/dev/null
  [[ ! -f "$PA_DIR/passwords/todelete.age" ]]
}

# --- Move ---

@test "move renames entry" {
  printf y | "$PA" add oldname 2>/dev/null
  "$PA" move oldname newname
  [[ ! -f "$PA_DIR/passwords/oldname.age" ]]
  [[ -f "$PA_DIR/passwords/newname.age" ]]
}

@test "move preserves password content" {
  printf y | "$PA" add moveme 2>/dev/null
  local before
  before=$("$PA" show moveme)
  "$PA" move moveme moved
  run "$PA" show moved
  [[ $output == "$before" ]]
}

# --- Rand ---

@test "rand generates password of default length" {
  run --separate-stderr "$PA" rand
  [[ $status -eq 0 ]]
  [[ ${#output} -eq 50 ]]
}

@test "rand respects custom length" {
  run --separate-stderr "$PA" rand 20
  [[ $status -eq 0 ]]
  [[ ${#output} -eq 20 ]]
}

# --- Validation errors ---

@test "add rejects duplicate entry" {
  printf y | "$PA" add existing 2>/dev/null
  run --separate-stderr "$PA" add existing
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"already exists"* ]]
}

@test "show rejects nonexistent entry" {
  run --separate-stderr "$PA" show nonexistent
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"doesn't exist"* ]]
}

@test "del rejects nonexistent entry" {
  run --separate-stderr "$PA" del nonexistent
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"doesn't exist"* ]]
}

@test "move rejects nonexistent source" {
  run --separate-stderr "$PA" move nonexistent newname
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"doesn't exist"* ]]
}

@test "add rejects missing name" {
  run --separate-stderr "$PA" add
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"missing [name]"* ]]
}

@test "add rejects path traversal" {
  run --separate-stderr "$PA" add ../escape
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"out of bounds"* ]]
}

@test "add rejects absolute path" {
  run --separate-stderr "$PA" add /absolute
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"start or end"* ]]
}

@test "list rejects nonexistent category" {
  run --separate-stderr "$PA" list nonexistent
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"doesn't exist"* ]]
}

# --- Git integration ---

# --- Meta ---

@test "meta creates name/meta entry" {
  EDITOR=true "$PA" meta myservice 2>/dev/null
  [[ -f "$PA_DIR/passwords/myservice/meta.age" ]]
}

@test "me shortcut creates name/meta entry" {
  EDITOR=true "$PA" me svc 2>/dev/null
  [[ -f "$PA_DIR/passwords/svc/meta.age" ]]
}

@test "meta first line is na" {
  EDITOR=true "$PA" meta check 2>/dev/null
  run "$PA" show check/meta
  [[ ${lines[0]} == "na" ]]
}

@test "meta prints status to stderr" {
  local stderr
  stderr=$(EDITOR=true "$PA" meta statuscheck 2>&1 1>/dev/null)
  [[ $stderr == *"saved meta 'statuscheck/meta' to the store."* ]]
}

@test "meta rejects missing name" {
  run --separate-stderr "$PA" meta
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"missing [name]"* ]]
}

@test "meta rejects duplicate" {
  EDITOR=true "$PA" meta duptest 2>/dev/null
  run --separate-stderr "$PA" meta duptest
  [[ $status -ne 0 ]]
  [[ ${stderr_lines[0]} == *"already exists"* ]]
}

@test "edit honors EDITOR with arguments" {
  local editor="$BATS_TEST_TMPDIR/editor"
  printf '#!/bin/sh\nprintf %%s "$2" >"$1"\nprintf edited >"$2"\n' >"$editor"
  chmod +x "$editor"
  EDITOR="$editor $BATS_TEST_TMPDIR/tmppath" "$PA" edit spaced 2>/dev/null
  run "$PA" show spaced
  [[ $output == "edited" ]]
  [[ ! -e $(<"$BATS_TEST_TMPDIR/tmppath") ]]
}

@test "edit removes temp file when EDITOR fails" {
  local editor="$BATS_TEST_TMPDIR/editor"
  printf '#!/bin/sh\nprintf %%s "$2" >"$1"\nexit 1\n' >"$editor"
  chmod +x "$editor"
  run --separate-stderr env EDITOR="$editor $BATS_TEST_TMPDIR/tmppath" "$PA" edit failing
  [[ $status -ne 0 ]]
  [[ $stderr == *"EDITOR exited non-zero"* ]]
  [[ ! -e $(<"$BATS_TEST_TMPDIR/tmppath") ]]
}

@test "meta creates nested entry" {
  EDITOR=true "$PA" meta wallet/exodus 2>/dev/null
  [[ -f "$PA_DIR/passwords/wallet/exodus/meta.age" ]]
}

# --- Dispatch ---

@test "rejects partial commands" {
  run "$PA" ad testentry
  [[ $status -eq 0 ]]
  [[ $output == *"a simple password manager"* ]]
}

@test "git tracking records commits when enabled" {
  export PA_DIR="$BATS_TEST_TMPDIR/pa-git"
  unset PA_NOGIT
  "$PA" list >/dev/null 2>&1
  [[ -d "$PA_DIR/passwords/.git" ]]
  printf y | "$PA" add gitentry 2>/dev/null
  run git -C "$PA_DIR/passwords" log --oneline
  [[ $output == *"add 'gitentry'"* ]]
}

# --- OTP ---

@test "otp rejects non-numeric HOTP counter without evaluating it" {
  command -v oathtool >/dev/null || skip "oathtool not installed"
  local marker="$BATS_TEST_TMPDIR/pwned"
  printf 'otpauth://hotp/x?secret=JBSWY3DPEHPK3PXP&counter=a[$(touch %s)]\n' "$marker" |
    "$PA" oi evil 2>/dev/null || :
  run --separate-stderr "$PA" oc evil
  [[ $status -ne 0 ]]
  [[ ! -e $marker ]]
}

# --- contrib/pa-pass ---

@test "pa-pass migrates a pass store" {
  local store="$BATS_TEST_TMPDIR/pass" bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$store/web" "$bin"
  printf 'secret1\n' >"$store/top.gpg"
  printf 'secret2\n' >"$store/web/my site.gpg"
  ln -s "$PA" "$bin/pa"
  cat >"$bin/gpg2" <<'EOF'
#!/usr/bin/env bash
cat "$2"
EOF
  chmod +x "$bin/gpg2"

  PATH="$bin:$PATH" PASSWORD_STORE_DIR="$store" \
    run "$BATS_TEST_DIRNAME/contrib/pa-pass"
  [[ $status -eq 0 ]]
  [[ $output == *"saved 'web/my site' to the store."* ]]
  [[ $("$PA" show top) == secret1 ]]
  [[ $("$PA" show "web/my site") == secret2 ]]
}

@test "pa-pass fails on a missing pass store" {
  PASSWORD_STORE_DIR="$BATS_TEST_TMPDIR/nope" \
    run "$BATS_TEST_DIRNAME/contrib/pa-pass"
  [[ $status -eq 1 ]]
  [[ $output == *"doesn't exist"* ]]
}

@test "pa-pass fails and leaves no entry when decryption fails" {
  local store="$BATS_TEST_TMPDIR/pass" bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$store" "$bin"
  printf 'secret\n' >"$store/broken.gpg"
  ln -s "$PA" "$bin/pa"
  printf '#!/usr/bin/env bash\nexit 2\n' >"$bin/gpg2"
  chmod +x "$bin/gpg2"

  PATH="$bin:$PATH" PASSWORD_STORE_DIR="$store" \
    run "$BATS_TEST_DIRNAME/contrib/pa-pass"
  [[ $status -eq 1 ]]
  [[ $output == *"couldn't migrate 'broken'"* ]]
  [[ ! -e "$PA_DIR/passwords/broken.age" ]]
}
