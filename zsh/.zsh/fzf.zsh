# ~/.zsh/fzf.zsh – fzf integration for the shell
# Requires: fzf, fd, bat, eza
# Colours: Tokyo Night Night — /usr/share/omarchy/themes/tokyo-night/colors.toml

# ── fzf defaults: fd for files, bat for previews ─────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height=60%
  --layout=reverse
  --border=sharp
  --info=inline
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --color=bg+:#24283b,bg:#1a1b26,spinner:#9ece6a,hl:#f7768e
  --color=fg:#a9b1d6,header:#7aa2f7,info:#ad8ee6,pointer:#9ece6a
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-a:select-all'
  --bind='ctrl-d:deselect-all'
"

# Ctrl-T: fuzzy file picker with bat preview
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range=:200 {}'
  --preview-window='right:55%:wrap'
"

# Alt-C: fuzzy directory jump with eza tree preview
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --icons --level=2 --color=always {}'
  --preview-window='right:40%'
"

# Ctrl-R: history search (no preview needed; show timestamps)
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window='down:3:wrap'
  --sort
  --exact
"

# Load fzf shell integration (key bindings and completion)
# Arch ships these at /usr/share/fzf/
if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi
if [[ -r /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# ── ff: fuzzy open file in nvim ───────────────────────────────────────────────
ff() {
    # Problem: navigating to nested files with cd+ls loops is slow.
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range=:200 {}') || return
    [[ -n "$file" ]] && nvim "$file"
}

# ── fh: fuzzy history execute ────────────────────────────────────────────────
fh() {
    # Problem: Ctrl-R is one item; fh lets you browse and execute any history entry.
    local cmd
    cmd=$(fc -l 1 | fzf --tac --no-sort --exact --query="${*:-}" | sed 's/^ *[0-9]* *//') || return
    [[ -n "$cmd" ]] && eval "$cmd"
}

# ── fkill: fuzzy process kill ─────────────────────────────────────────────────
fkill() {
    # Problem: finding a PID to kill is multiple steps without this.
    local pid
    pid=$(ps -u "$USER" -o pid,cmd --no-headers |
          fzf --multi --preview 'echo {}' --preview-window=down:3:wrap |
          awk '{print $1}') || return
    [[ -n "$pid" ]] && kill -"${1:-9}" $pid
}
