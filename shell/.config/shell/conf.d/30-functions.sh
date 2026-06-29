# 30-functions.sh — shell functions. Portable unless noted; macOS-only ones are
# gated on is_mac. Apple/work + personal-infra functions live in the private
# overlay (see private.sh.example), not here.

# List the functions defined in this file
functions() { grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' "$XDG_CONFIG_HOME/shell/conf.d/30-functions.sh"; }

# --- fzf-powered pickers ----------------------------------------------------
qq() {  # fuzzy-pick file(s) with a bat preview
    fzf --scheme=path --multi --cycle --keep-right \
        --preview "bat --style=full --color=always {}" --bind "space:select"
}
gq() {  # fuzzy-pick changed file(s) with a delta preview
    git diff --name-only | fzf --scheme=path --multi --cycle --keep-right \
        --preview "git diff -- {} | delta" --bind "space:select"
}
bq() {  # fuzzy-pick a branch with a delta preview
    git for-each-ref --format='%(refname:short)' refs/heads/ | fzf --cycle --keep-right \
        --preview "git show {} | delta" --bind "space:select"
}
sbq() { local branch; branch="$(bq)" && git checkout "$branch"; }
gaq() { local files; files="$(gq)"; echo "$files" | xargs git diff; echo "$files" | xargs git add --; }
gsq() { local files; files="$(gq)"; echo "$files" | xargs git diff; echo "$files" | xargs git stash --; }
grq() {
    local files; files="$(gq)"
    echo "$files" | xargs git diff
    read -p "Are you sure? " -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]] && echo "$files" | xargs git restore
}
vq() { local files; files="$(qq)"; history -s "nvim $(echo "$files" | xargs)"; echo "$files" | xargs nvim; }
cdq() {  # fuzzy-cd into a subdirectory
    local base="${1:-$(pwd)}"
    cd "$(find "$base" -type d -not -name '.*' -not -path '*.git*' -maxdepth 4 | fzf)" || return
}

# --- history ----------------------------------------------------------------
clean-eternal-history() { ruby -ne '/" \d+  \d+ (.+)"/ =~ $_; puts $1'; }
eternal-history() { clean-eternal-history < ~/.bash_eternal_history; }
hq() {  # fuzzy-search the eternal history and stage the chosen command
    local cmd; cmd=$(tail -500 ~/.bash_eternal_history | clean-eternal-history | sort -u | fzf)
    [ -n "$cmd" ] && history -s "$cmd" && eval "$cmd"
}
[[ "${SHELLOPTS}" =~ (vi|emacs) ]] && bind -x '"\C-r":"hq\n"' 2>/dev/null

# --- small helpers ----------------------------------------------------------
alias returns="?"
# `function` keyword form (not `?()`) — bash rejects `?` as a POSIX function name.
function ? { local val=$?; if [ $# -gt 0 ]; then "$@"; val=$?; fi; echo "returned $val"; }

# Interactive rename when called with a single existing file (else real mv)
mv() {
    if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then command mv "$@"; return; fi
    local newfilename; read -ei "$1" newfilename; command mv -v "$1" "$newfilename"
}

mkd() { mkdir -p "$@" && cd "$@" || return; }            # make a dir and enter it
fs() {                                                    # size of file(s)/dir
    if du -b /dev/null >/dev/null 2>&1; then local arg=-sbh; else local arg=-sh; fi
    if [ -n "$*" ]; then du $arg -- "$@"; else du $arg .[^.]* *; fi
}
gitop() {                                                 # cd to the git repo root
    local root; root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not a git repository."; return 1; }
    cd "$root" || return
}
reponame() { basename "$(git rev-parse --show-toplevel)"; }
if has git; then diff() { git diff --no-index --color-words "$@"; }; fi   # colorful diff
calc() {
    local result; result="$(printf 'scale=10;%s\n' "$*" | bc --mathlib | tr -d '\\\n')"
    if [[ "$result" == *.* ]]; then
        printf '%s' "$result" | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/0*$//;s/\.$//'
    else printf '%s' "$result"; fi
    printf '\n'
}
j() { if [ $# -eq 0 ]; then jobs; else jmp "$@"; fi; }

# --- directory marks --------------------------------------------------------
export MARKPATH="$HOME/.marks"
jump() { cd -P "$MARKPATH/$1"* 2>/dev/null || echo "No such mark: $1"; }
jmp() {
    if [ $# -eq 0 ]; then echo "Jump where?"; marks; return; fi
    jump "$1"; shift
    while [ $# -gt 0 ]; do tmux neww -c "$MARKPATH/$1"* 2>/dev/null; shift; done
}
mark() {
    if [ $# -eq 1 ]; then mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
    else echo "Usage: mark <name>"; fi
}
unmark() { [ $# -eq 1 ] || { echo "Usage: unmark <mark>"; return 1; }; rm -iv "$MARKPATH/$1"; }
marks() { ls -l "$MARKPATH" 2>/dev/null | sed 's/  */ /g' | cut -d' ' -f9- || echo "No marks set."; }

# --- scratch directories ----------------------------------------------------
scratchd() {
    local dir="$HOME/Source/.scratch/$(date +%s)"
    export PS1="$PS1_SCRATCH" SCRATCH_ORIGINAL_DIR="$(pwd)" SCRATCH_CURRENT_SCRATCH_DIR="$dir"
    mkdir -p "$dir"; cd "$dir" || return
    [ $# -eq 1 ] && nvim "$1"
}
alias scratched="scratchd"
unscratch() {
    if [ $# -lt 2 ]; then
        export PS1="$PS1_DEFAULT"
        if [ "$1" = "-r" ]; then cd "$SCRATCH_ORIGINAL_DIR" || return; rm -rf "$SCRATCH_CURRENT_SCRATCH_DIR"
        else export SCRATCH_LAST_SCRATCH_DIR="$(pwd)"; cd "$SCRATCH_ORIGINAL_DIR" || return; fi
        unset SCRATCH_ORIGINAL_DIR SCRATCH_CURRENT_SCRATCH_DIR
    elif [ $# -eq 2 ]; then echo "removing $2..."; rm -rv "$HOME/Source/.scratch/$2"; fi
}
rescratch() {
    local target="${SCRATCH_CURRENT_SCRATCH_DIR:-$SCRATCH_LAST_SCRATCH_DIR}"
    [ -z "$target" ] && { echo "No scratch directory."; return 1; }
    [ -d "$target" ] || { echo "Scratch directory was deleted."; unset SCRATCH_LAST_SCRATCH_DIR; return 2; }
    export SCRATCH_ORIGINAL_DIR="$(pwd)" PS1="$PS1_SCRATCH" SCRATCH_CURRENT_SCRATCH_DIR="$target"
    cd "$target" || return
}

# --- random generators ------------------------------------------------------
randompass() { ruby -r securerandom -e "puts SecureRandom.base64(${1:-})"; }
export DEFAULT_WORDLIST="/usr/share/dict/words"
randomword() {
    local size; size=$(wc -w "${WORDLIST:-$DEFAULT_WORDLIST}" | awk '{print $1}')
    sed -n "$(( (RANDOM * RANDOM) % size ))p" "${WORDLIST:-$DEFAULT_WORDLIST}"
}
randomdictwords() {
    local word; word="$(WORDLIST=/usr/share/dict/words randomword)"
    local count=$(( ${1:-1} - 1 )) sep="${2:- }"
    while [ "$count" -gt 0 ]; do word="${word}${sep}$(randomword)"; count=$((count-1)); done
    echo "$word"
}
randompassphrase() { echo "$(randomword)-$RANDOM-$(randomword)-$RANDOM-$(randomword)"; }
randomhex() { dd if=/dev/urandom bs=1024 count=1 2>/dev/null | shasum -a 256 | awk '{print $1}'; }

# --- http / web -------------------------------------------------------------
server() { local port="${1:-8000}"; sleep 1 && openurl "http://localhost:${port}/" & python3 -m http.server "$port"; }
gz() {
    local o g; o=$(wc -c <"$1"); g=$(gzip -c "$1" | wc -c)
    printf 'orig: %d bytes\ngzip: %d bytes (%2.2f%%)\n' "$o" "$g" "$(echo "$g * 100 / $o" | bc -l)"
}
httpcompression() { local e; e="$(curl -LIs -H 'Accept-Encoding: gzip,deflate' "$1" | grep -i '^Content-Encoding:')" && echo "$1 is encoded using ${e#* }" || echo "$1 is not using any encoding"; }
gurl() { curl -sH "Accept-Encoding: gzip" "$@" | gunzip; }
json() { if [ -t 0 ]; then python3 -mjson.tool <<<"$*"; else python3 -mjson.tool; fi; }
digga() { dig +nocmd "$1" any +multiline +noall +answer; }
dataurl() {
    local mime; mime="$(file -b --mime-type "$1")"; [[ $mime == text/* ]] && mime="${mime};charset=utf-8"
    echo "data:${mime};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}
responsetime() { curl -w '\nLookup:\t%{time_namelookup}\nConnect:\t%{time_connect}\nStart:\t%{time_starttransfer}\nTotal:\t%{time_total}\n' -o /dev/null -s "$1"; }
getcertnames() {
    [ -z "$1" ] && { echo "ERROR: no domain specified."; return 1; }
    local tmp; tmp=$(echo -e "GET / HTTP/1.0\nEOT" | openssl s_client -connect "${1}:443" 2>&1)
    [[ "$tmp" == *"BEGIN CERTIFICATE"* ]] || { echo "ERROR: certificate not found."; return 1; }
    echo "$tmp" | openssl x509 -noout -text | grep -E 'Subject:|DNS:'
}
escape() { printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u); [ -t 1 ] && echo; }
unidecode() { perl -e "binmode(STDOUT, ':utf8'); print \"$@\""; [ -t 1 ] && echo; }
codepoint() { perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))"; [ -t 1 ] && echo; }
rfc() { curl -s "https://www.rfc-editor.org/rfc/rfc$(printf '%d' "$1").txt" | less; }
explain() { local url="https://explainshell.com/explain/$1?args="; shift; for i in "$@"; do url="$url$i+"; done; openurl "$url"; }
gitplz() { openurl "https://google.com/search?q=git+$(IFS=+; echo "$*")"; }

# --- search / files ---------------------------------------------------------
whatlistenson() { grep "\s$1/" /etc/services; }
alias whatrunson="whatlistenson"
removedupes() { md5sum * | sort | awk 'BEGIN{h=""} $1==h{print $2} {h=$1}' | xargs rm -i; }

# --- tmux -------------------------------------------------------------------
tmux_create_or_attach() { tmux has-session -t "$1" 2>/dev/null && tmux attach -t "$1" || tmux new -s "$1"; }
sesh() {
    if [ $# -eq 0 ]; then (tmux list-sessions 2>/dev/null) || echo "No active sessions."; return; fi
    case "$1" in
        new) tmux new -s "$2" ;;
        *) if [ -n "$TMUX" ]; then tmux switch -t "$1"; else tmux attach -t "$1"; fi ;;
    esac
}

# --- media ------------------------------------------------------------------
trimclip() {
    [ $# -eq 4 ] || { echo "Usage: trimclip <in> <start> <duration> <out>"; return 1; }
    ffmpeg -i "$1" -vcodec copy -acodec copy -ss "$2" -t "$3" "$4"
}
gif-ify() {
    [ -n "$1" ] && [ -n "$2" ] || { echo "Usage: gif-ify <input.mov> <output.gif>"; return 1; }
    ffmpeg -i "$1" -pix_fmt rgb24 /tmp/gifify.gif && convert -layers Optimize /tmp/gifify.gif "$2" && rm -f /tmp/gifify.gif
}

# --- macOS only -------------------------------------------------------------
if is_mac; then
    note()   { local t; if [ -t 0 ]; then t="$1"; else t=$(cat); fi; osascript >/dev/null <<EOF
tell application "Notes" to tell account "iCloud" to tell folder "Notes" to make new note with properties {name:"$t", body:"$t"}
EOF
    }
    remind() { local t; if [ -t 0 ]; then t="$1"; else t=$(cat); fi; osascript >/dev/null <<EOF
tell application "Reminders" to tell the default list to make new reminder with properties {name:"$t"}
EOF
    }
    unquarantine() { for a in com.apple.metadata:kMDItemDownloadedDate com.apple.metadata:kMDItemWhereFroms com.apple.quarantine; do xattr -r -d "$a" "$@"; done; }
    dash() { [ $# -lt 2 ] && { echo "Usage: dash <docs> <query>"; return 1; }; local docs=$1; shift; openurl "dash://${docs}:$1"; }
fi
