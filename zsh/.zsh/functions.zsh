# ~/.zsh/functions.zsh – shell functions
# Each function has a header comment naming the problem it solves.

# ── mkcd: create directory and enter it ───────────────────────────────────────
mkcd() {
    # Problem: mkdir then cd is two commands; one is always enough.
    [[ -z "$1" ]] && { echo "Usage: mkcd <dir>" >&2; return 1; }
    mkdir -p "$1" && cd "$1"
}

# ── gclone: clone a GitHub repo and cd into it ────────────────────────────────
gclone() {
    # Problem: git clone then cd is tedious for repos cloned frequently.
    # Usage: gclone owner/repo  OR  gclone full-url
    local target="$1"
    [[ -z "$target" ]] && { echo "Usage: gclone <owner/repo|url>" >&2; return 1; }

    # Convert short-form owner/repo to SSH URL.
    if [[ "$target" != *://* && "$target" != git@* ]]; then
        target="git@github.com:${target}.git"
    fi

    local repo_name
    repo_name="$(basename "${target%.git}")"
    git clone "$target" && cd "$repo_name"
}

# ── ginit: init a new Go module and create main.go ────────────────────────────
ginit() {
    # Problem: starting a new Go project requires several boilerplate steps.
    # Usage: ginit [module-path]
    local module="${1:-$(basename "$(pwd)")}"
    go mod init "$module"
    cat > main.go <<'EOF'
package main

import "fmt"

func main() {
	fmt.Println("hello")
}
EOF
    echo "Initialized Go module: $module"
}

# ── gotest-watch: run tests on file change using entr ─────────────────────────
gotest_watch() {
    # Problem: waiting to re-run tests manually breaks flow.
    if ! command -v entr &>/dev/null; then
        echo "entr is not installed (pacman -S entr)" >&2; return 1
    fi
    find . -name '*.go' | entr -c go test ./...
}

# ── port: show what's listening on a port ─────────────────────────────────────
port() {
    # Problem: ss/netstat output is noisy; just show who owns the port.
    [[ -z "$1" ]] && { echo "Usage: port <number>" >&2; return 1; }
    ss -tlnp "sport = :$1"
}

# ── killport: kill whatever is listening on a port ────────────────────────────
killport() {
    # Problem: freeing a port is a three-command lookup without this.
    [[ -z "$1" ]] && { echo "Usage: killport <number>" >&2; return 1; }
    local pid
    pid="$(ss -tlnp "sport = :$1" | awk 'NR>1 {print $6}' | grep -oP 'pid=\K[0-9]+')"
    if [[ -z "$pid" ]]; then
        echo "Nothing listening on port $1"
        return 0
    fi
    echo "Killing PID $pid on port $1"
    kill -9 "$pid"
}

# ── lg: show last N git commits in oneline format (default 10) ────────────────
# (Separate from alias because it takes an arg)
glog() {
    # Problem: git log with options is long to type; most useful default is oneline+graph.
    git log --oneline --graph --decorate --all -"${1:-10}"
}

# ── ghpr: open a GitHub pull request for the current branch ───────────────────
ghpr() {
    # Problem: opening a PR requires clicking; one command is faster.
    local remote
    remote="$(git remote get-url origin 2>/dev/null)" || { echo "Not a git repo" >&2; return 1; }
    local repo
    repo="$(echo "$remote" | sed -E 's|git@github.com:||; s|\.git$||; s|https://github.com/||')"
    local branch
    branch="$(git branch --show-current)"
    local url="https://github.com/${repo}/compare/${branch}?expand=1"
    echo "Opening: $url"
    xdg-open "$url" 2>/dev/null || echo "$url"
}

# ── up: update mise toolchains ─────────────────────────────────────────────────
up() {
    # Problem: keeping runtimes fresh requires several commands.
    echo "==> mise upgrade"
    mise upgrade
}

# ── dotfiles: jump to the dotfiles repo ───────────────────────────────────────
dotfiles() {
    # Problem: the dotfiles repo path changes between machines; one function, one place.
    local df_dir="${DOTFILES_DIR:-${HOME}/Alien/dotfiles}"
    if [[ -d "$df_dir" ]]; then
        cd "$df_dir"
    else
        echo "Dotfiles directory not found: $df_dir" >&2
        return 1
    fi
}

# ── json: pretty-print JSON (stdin or file) ────────────────────────────────────
json() {
    # Problem: raw JSON from curl is unreadable; bat adds syntax highlighting.
    if [[ -n "$1" ]]; then
        jq . "$1" | bat --language=json --paging=never
    else
        jq . | bat --language=json --paging=never
    fi
}
