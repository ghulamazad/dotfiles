# ~/.zsh/aliases.zsh – shell aliases
# Each alias has a one-line comment naming the problem it solves.
# Guards prevent errors when optional tools are not installed.

# ── Navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'                  # return to previous directory

# ── ls → eza (modern ls with git status) ─────────────────────────────────────
# if command -v eza &>/dev/null; then
#     alias ls='eza --icons --group-directories-first'
#     alias ll='eza -lah --icons --group-directories-first --git'
#     alias lt='eza --tree --icons --level=2 --group-directories-first'
#     alias la='eza -a --icons --group-directories-first'
# else
#     alias ll='ls -lAh'
#     alias la='ls -A'
# fi

if command -v eza &>/dev/null; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
else
    alias ll='ls -lAh'
    alias la='ls -A'
fi

# ── Editor ────────────────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# ── bat (better cat) ─────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never --theme=gruvbox-dark'
fi

# ── Git – daily driver shortcuts ──────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'                          # compact status
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'           # amend without reopening editor
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gbd='git branch -d'
alias gp='git push'
alias gpf='git push --force-with-lease'            # safe force push
alias gl='git pull --ff-only'                      # fast-forward only pull
alias gf='git fetch --prune'                       # prune stale remote branches
alias gd='git diff'
alias gds='git diff --staged'
alias glg='git log --oneline --graph --decorate --all -20'  # concise log graph
alias gst='git stash'
alias gstp='git stash pop'
alias gr='git rebase'
alias gri='git rebase -i'
alias grm='git rebase -i origin/main'              # interactive rebase onto main
alias grh='git reset --hard'
alias grs='git restore'

# lazygit: TUI for interactive staging/diffing
if command -v lazygit &>/dev/null; then
    alias lg='lazygit'
fi

# ── Go ────────────────────────────────────────────────────────────────────────
alias gb='go build ./...'           # build whole module
alias gt='go test ./...'            # test whole module
alias gtv='go test -v ./...'        # verbose tests
alias gtrace='go test -race ./...'  # race detector
alias gtr='go test -run'            # run a specific test by name prefix
alias gmod='go mod tidy'            # clean up go.mod/go.sum
alias gvet='go vet ./...'           # static analysis
alias gcov='go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out'

# golangci-lint: run all linters
if command -v golangci-lint &>/dev/null; then
    alias glint='golangci-lint run ./...'
fi

# ── Docker ────────────────────────────────────────────────────────────────────
if command -v docker &>/dev/null; then
    alias d='docker'
    alias dc='docker compose'
    alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dprune='docker system prune -f'           # reclaim disk space
    alias dlogs='docker compose logs -f --tail=50'  # tail compose logs
fi

# ── Misc ─────────────────────────────────────────────────────────────────────
alias mkdir='mkdir -p'              # always create parents
alias cp='cp -i'                    # prompt before overwrite
alias mv='mv -i'                    # prompt before overwrite
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias path='printf "%s\n" "${path[@]}"'  # one entry per line
alias reload='exec zsh'             # reload shell without losing session
alias myip='curl -s ifconfig.me'
