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
  run "$PA" rand
  [[ $status -eq 0 ]]
  [[ ${#output} -eq 50 ]]
}

@test "rand respects custom length" {
  run "$PA" rand 20
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
