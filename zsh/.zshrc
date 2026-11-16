# ~/.zshrc – main zsh configuration
# Target: interactive startup < 100 ms.  No framework, no plugin manager.

# ── Environment ────────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-RFX"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # man pages via bat

# Prefer XDG paths for common tools
export HISTFILE="${XDG_DATA_HOME}/zsh/history"
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# ── PATH (order matters: user bins first) ─────────────────────────────────────
path=(
    "${HOME}/.local/bin"
    "${HOME}/.local/scripts"
    "${GOBIN}"
    "${CARGO_HOME}/bin"
    "$path[@]"
)
export PATH

# ── History ────────────────────────────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_IGNORE_DUPS      # no consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS  # deduplicate across sessions
setopt HIST_FIND_NO_DUPS     # skip dups in history search
setopt HIST_SAVE_NO_DUPS     # don't write dups to file
setopt HIST_REDUCE_BLANKS    # trim extra whitespace
setopt INC_APPEND_HISTORY    # write immediately, not on shell exit
setopt SHARE_HISTORY         # read shared history from all sessions

# ── Options ────────────────────────────────────────────────────────────────────
setopt AUTO_PUSHD            # cd pushes to directory stack
setopt PUSHD_IGNORE_DUPS     # no duplicate dirs on stack
setopt PUSHD_SILENT          # quiet pushd
setopt CORRECT               # spell-correct commands
setopt NO_BEEP               # silence
setopt INTERACTIVE_COMMENTS  # allow # comments in interactive shell
setopt GLOB_DOTS             # include dotfiles in globs

# ── Completion ─────────────────────────────────────────────────────────────────
# Once-a-day full rebuild; setopt extendedglob scoped to just this check.
autoload -Uz compinit

_zcompdump="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "$(dirname "$_zcompdump")"

{
    setopt extendedglob
    # Rebuild if dump is older than 20 hours (~once daily).
    if [[ -n "${_zcompdump}"(#qN.mh+20) ]]; then
        compinit -d "$_zcompdump"
    else
        compinit -C -d "$_zcompdump"
    fi
    unsetopt extendedglob
} 2>/dev/null

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'

# ── mise (runtime version manager) ─────────────────────────────────────────────
# Activate shims; must come before anything that calls node/go/python.
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

# ── zoxide (smart cd) ──────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"  # replaces cd with zoxide
fi

# ── starship prompt ────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── Load sub-configs ───────────────────────────────────────────────────────────
for _f in "${HOME}/.zsh/"*.zsh; do
    [[ -r "$_f" ]] && source "$_f"
done
unset _f

# ── Plugins (sourced last – highest startup cost) ─────────────────────────────
# zsh-autosuggestions: fish-style inline history completion
_zas="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$_zas" ]] && source "$_zas"
unset _zas

# zsh-syntax-highlighting: real-time command coloring (must be last)
_zsh_hl="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$_zsh_hl" ]] && source "$_zsh_hl"
unset _zsh_hl

# ── Key bindings ──────────────────────────────────────────────────────────────
bindkey -e                              # emacs keys (works well with readline)
bindkey '^[[A' history-search-backward  # up arrow: history search
bindkey '^[[B' history-search-forward   # down arrow
bindkey '^[[1;5C' forward-word          # ctrl+right
bindkey '^[[1;5D' backward-word         # ctrl+left
bindkey -s '^f' "tmux-sessionizer\n"    # ctrl+f → tmux project picker
