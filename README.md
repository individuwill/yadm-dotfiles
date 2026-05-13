# dotfiles

Personal dotfiles managed with [yadm](https://yadm.io). One repo serves
multiple machines — macOS work, macOS home, and Linux home — using yadm's
class + OS tagging to keep the divergent bits separate.

---

## At a glance

- **Tool:** yadm (a thin wrapper over git, with alt-file resolution and
  encryption baked in).
- **Identity axis (class):** `Home` (personal use, currently macOS + Linux)
  vs `Work` (work laptop only).
- **OS axis:** `Darwin` (macOS) vs `Linux` (Debian-style personal box).
  Orthogonal to class.
- **Files that vary** live under `.config/yadm/alt/` with `##` tag suffixes;
  yadm symlinks the matching variant into place.
- **Secrets** live in `.local/share/yadm/archive` (openssl-encrypted) and
  are listed in `.config/yadm/encrypt`.
- **Bootstrap** runs automatically after first clone and dispatches by OS.

---

## Layout

```
.
├── .config/yadm/
│   ├── bootstrap              # entry point, dispatches by OS
│   ├── bootstrap.d/
│   │   ├── darwin             # brew + cask installs (idempotent)
│   │   ├── linux              # check-only: reports missing tools
│   │   └── common             # decrypt, refresh alt, class reminder
│   ├── config                 # yadm encryption config
│   ├── encrypt                # paths to include in the encrypted archive
│   └── alt/                   # tag-suffixed variants resolved by `yadm alt`
│       ├── .myprofile.local##c.Home
│       ├── .myprofile.local##c.Work
│       ├── .myprofile.os##o.Darwin
│       ├── .myprofile.os##o.Linux
│       ├── .ssh/config.local##c.Home
│       ├── .ssh/config.local##c.Work
│       └── .config/.../*##c.{Home,Work}
├── .local/share/yadm/archive  # encrypted bundle of secrets (gpg/openssl)
├── .zshrc / .myprofile        # portable shell config (sources .os + .local)
├── .tmux.conf                 # OS-aware via if-shell branches
├── .vimrc / .config/nvim/     # portable
└── .hammerspoon/ .config/{sketchybar,aerospace}/  # macOS-only (inert on Linux)
```

---

## Tagging model

yadm scans `.config/yadm/alt/` for files named `<target>##<tag1>.<value1>,<tag2>.<value2>...`
and symlinks the best-matching variant to its target path in `$HOME`.

The two tags this repo uses:

| Tag | Values | Set via |
|---|---|---|
| `c` (class) | `Home`, `Work` | `yadm config local.class <value>` |
| `o` (os) | `Darwin`, `Linux` | derived from `uname -s` automatically |

(yadm supports more — `h.hostname`, `u.user`, `a.arch`, `d.distro` — but
this repo currently only uses `c` and `o`. Add others as needed.)

### Examples

```
.myprofile.local##c.Work             # only on machines with class=Work
.myprofile.os##o.Darwin              # only on macOS, any class
.myprofile.os##o.Linux               # only on Linux, any class
.ssh/config.local##c.Home,o.Linux    # only on Linux + Home (if ever needed)
.1password/agent.sock##user.will.smith,os.Darwin  # only my mac user (long form also valid)
```

### How the axes are used in this repo

- **Class** = identity. Work vs personal. Things like aliases for
  internal tools, GAM commands, Netskope env, work-specific SSH hosts.
- **OS** = platform. Things like homebrew paths, mac-only aliases
  (`flushdns`), zsh-plugin source paths.
- Both home machines (mac and linux) currently use **class `Home`**.
  The Linux box is "Will's home computer that happens to be Linux,"
  not a separate identity.

### Adding a new conditional file

1. Decide which axis (or both) actually differs.
2. Put each variant under `.config/yadm/alt/` with the appropriate tag.
3. `yadm add <variant-path>` for each.
4. `yadm alt` to refresh symlinks on the current machine.

The tag suffix lives only on the file in the alt directory — the symlinked
target in `$HOME` is the bare name (`~/.myprofile.local`).

### Templating (alternative to alt files)

yadm also supports `##template.jinja2` files where one file branches
internally on `yadm.class`, `yadm.os`, etc. Not currently used here, but
fair game when a file has lots of small divergences that would otherwise
duplicate.

---

## Encryption

- Files listed in `.config/yadm/encrypt` are bundled into
  `.local/share/yadm/archive` via openssl (see `.config/yadm/config`).
- `yadm encrypt` produces/refreshes the archive. Commit it.
- `yadm decrypt` extracts on a new machine.
- The encrypt list is git-tracked but the unencrypted source files in
  `$HOME` are **not** tracked. The archive is the only thing that crosses
  machines.

Currently encrypted: `.config/yadm/test_encrypt` (placeholder; add real
secrets here as needed).

---

## First-time setup on a new machine

This procedure works on a fresh macOS or Debian box. Tools assumed present:
`zsh`, `git`, `curl`, `ssh`. On Debian: `apt install zsh git curl yadm`.
On macOS: install Homebrew first (or skip and let bootstrap do it after the
clone — see step 6).

### 1. Generate a per-machine deploy key

Each machine gets its own keypair, used **only** for talking to this
repo on GitHub. It never goes near 1Password or any other host.

```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_yadm.key -C "yadm@$(hostname)" -N ""
chmod 600 ~/.ssh/id_rsa_yadm.key
```

### 2. Register it as a GitHub deploy key

On <https://github.com/individuwill/yadm-dotfiles/settings/keys>:
- "Add deploy key"
- Title: hostname of the new machine
- Paste contents of `~/.ssh/id_rsa_yadm.key.pub`
- Tick "Allow write access" (so `yadm push` works from this machine)

### 3. Clone with an explicit identity

Bypassing `~/.ssh/config` entirely — this avoids the chicken-and-egg
where the SSH config you need is inside the repo you're trying to clone:

```sh
yadm clone \
  -c "core.sshCommand=ssh -i ~/.ssh/id_rsa_yadm.key -o IdentitiesOnly=yes" \
  git@github.com:individuwill/yadm-dotfiles.git
```

yadm will check out the files into `$HOME`. If anything conflicts with
files you've already placed (e.g. you pre-created `~/.ssh/config` for some
other reason), yadm will refuse — back those files up or `yadm checkout
-f -- <path>` to take the tracked version.

### 4. Set the class

```sh
yadm config local.class Home      # personal machine (mac or linux)
# or
yadm config local.class Work      # work laptop
```

Then refresh alt-symlinks:

```sh
yadm alt
```

### 5. Switch the remote to the host-aliased form

The yadm-tracked `~/.ssh/config` defines `Host github.com-yadm` pointing
at GitHub with `IdentityFile ~/.ssh/id_rsa_yadm.key, IdentitiesOnly yes`.
That keeps yadm git ops decoupled from the 1Password agent (which serves
all your other SSH keys). Switch the remote URL to use it:

```sh
yadm remote set-url origin git@github.com-yadm:individuwill/yadm-dotfiles.git
```

After this, `yadm pull` / `yadm push` "just work" without needing
`core.sshCommand`.

### 6. Run the bootstrap

```sh
yadm bootstrap
```

- **macOS:** installs Homebrew (if missing), then brew packages and casks
  used by the dotfiles. Safe to re-run — each install is guarded by
  `brew list … || brew install`.
- **Linux:** does **not** install anything. Checks for the tools the
  dotfiles assume, prints what's missing, exits non-zero if any *required*
  tool is absent. Install missing tools with your distro's package manager
  (`apt`, `pacman`, `dnf`, `nix`, `cargo`, `mise`, etc.) and re-run.

### 7. Decrypt secrets

```sh
yadm decrypt
```

Prompts for the archive passphrase. Restores any files listed in
`.config/yadm/encrypt`.

### 8. Open a new shell

```sh
exec zsh -l
```

Plugins, prompt, completions, and PATH should all initialize without
errors. Anything OS-specific (homebrew zsh plugins on mac, apt zsh plugins
on linux) is sourced via the `~/.myprofile.os` alt symlink and silently
skipped if not installed.

---

## Bootstrap details

`yadm bootstrap` is just:

```sh
case "$(uname -s)" in
  Darwin) .config/yadm/bootstrap.d/darwin ;;
  Linux)  .config/yadm/bootstrap.d/linux  ;;
esac
.config/yadm/bootstrap.d/common
```

### `bootstrap.d/darwin`

- Installs Homebrew if missing.
- Installs `uv` if missing.
- Installs each formula and cask iff not already present.
- Safe to re-run any time after editing.

### `bootstrap.d/linux`

- Verifies required tools (`zsh`, `git`, `curl`) — non-zero exit if any
  are absent.
- Reports missing recommended tools (`starship`, `lsd`, `bat`, `fd`, `fzf`,
  `ripgrep`, `jq`, `direnv`, `neovim`, `tmux`, `xclip`, `wl-copy`, `uv`,
  `mise`).
- Notes missing zsh plugin paths under `/usr/share/`.
- Does **not** install anything. You decide which tools to install
  with which package manager.

### `bootstrap.d/common`

- `yadm decrypt` if an archive is present.
- `yadm alt` to refresh symlinks.
- Prints a reminder if `local.class` is unset.

---

## Day-to-day operations

```sh
yadm status                          # like git status, scoped to $HOME
yadm add ~/.config/foo/config        # track a new file
yadm commit -m "..."
yadm push                            # to github (via the github.com-yadm alias)

# Refresh alt symlinks (after switching class, or adding new alt variants)
yadm alt

# Re-encrypt secrets after editing them
yadm encrypt
yadm add .local/share/yadm/archive
yadm commit -m "rotate secrets"

# Pull updates on another machine
yadm pull
yadm alt              # if alt variants changed
yadm bootstrap        # if bootstrap or installed-tool list changed
yadm decrypt          # if the archive changed
```

---

## Migration notes (from the shared-key setup)

Earlier, the yadm-git private key (`~/.ssh/id_rsa_yadm.key`) was bundled
inside the encrypted archive and shared across machines. That created a
chicken-and-egg on first clone: the key you need to clone the repo lives
inside the repo. The current scheme uses a **per-machine deploy key**
instead — each machine generates its own keypair, registers it as a
deploy key on GitHub, and the key never leaves that machine.

If you previously cloned with the shared-key scheme:

1. On each existing machine, generate a fresh per-machine key (step 1
   above) and add it as a deploy key on GitHub (step 2).
2. On each machine, delete the now-obsolete shared key:
   `rm ~/.ssh/id_rsa_yadm.key && ssh-keygen ... -f ~/.ssh/id_rsa_yadm.key ...`
   (the path stays the same so `~/.ssh/config` doesn't need to change).
3. On GitHub, revoke the old shared deploy key.
4. The `.ssh/*.key` line has been removed from `.config/yadm/encrypt`,
   so the archive will no longer carry a key. Run `yadm encrypt` once
   to refresh the archive (it'll now only contain whatever else is in
   the encrypt list), then `yadm add` + `yadm commit` it.

---

## Mac-only dotfiles on Linux

- **`Library/Application Support/Leader Key/config.json`** — gated via
  `.config/yadm/alt/Library/.../config.json##o.Darwin`. Does NOT appear
  on Linux.
- **`.hammerspoon/`, `.config/sketchybar/`, `.config/aerospace/`** —
  tracked unconditionally. Files exist on Linux but nothing reads them
  (the apps don't exist there). If they ever start causing problems,
  move each top-level directory into `.config/yadm/alt/<name>##o.Darwin/`
  and yadm will only symlink it on macOS.

---

## Useful yadm references

- `yadm gh-pages` — official docs locally.
- <https://yadm.io/docs/alternates> — alt-file tag reference.
- <https://yadm.io/docs/encryption> — encryption details.
- `.config/yadm/alt/test##template` — a small jinja2 template demo
  (illustrates branching inside a single file).
