# ~/.zshrc. Deliberately small: no framework, no plugin manager.
# Startup cost: one compinit (cached) plus two sourced plugin files.

# --- Environment --------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R'
export MANPAGER='nvim +Man!'
# Parallel builds by default. Override per command: make -j2
export MAKEFLAGS="-j$(nproc 2>/dev/null || echo 2)"
# Colored GCC/Clang diagnostics. Compiler FLAGS are intentionally NOT set
# globally: the Linux kernel (kbuild) and other projects choose their own.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# Keep local binaries on PATH without duplicating entries.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# --- History ------------------------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY

# --- Shell options ------------------------------------------------------
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS
setopt NO_BEEP

# --- Completion ---------------------------------------------------------
# Full security check + rebuild only if the dump is missing or older than a
# day; otherwise `compinit -C` skips the check for a faster start.
autoload -Uz compinit
_zcomp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zcomp:h}"
if [[ ! -f $_zcomp || -n "$(find "$_zcomp" -mtime +1 2>/dev/null)" ]]; then
    compinit -d "$_zcomp"
else
    compinit -C -d "$_zcomp"
fi
unset _zcomp
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- Prompt: directory, git branch, exit status -------------------------
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{magenta}%b%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '

# --- Aliases --------------------------------------------------------------
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lAh'
alias grep='grep --color=auto'
alias v='nvim'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git pull --ff-only'

# Build helpers for systems work. compile_commands.json feeds clangd.
alias cmk='cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja && cmake --build build'
alias bear-make='bear -- make'

# --- Plugins (Arch/CachyOS package paths; skipped silently if missing) ----
# pacman -S zsh-autosuggestions zsh-syntax-highlighting
_zp=/usr/share/zsh/plugins
[[ -r $_zp/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $_zp/zsh-autosuggestions/zsh-autosuggestions.zsh
# Syntax highlighting must be sourced last.
[[ -r $_zp/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source $_zp/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset _zp
