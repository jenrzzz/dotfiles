# 20-aliases.sh — aliases. Portable ones first; macOS- and linux-specific blocks
# are gated on is_mac / is_linux. Apple/work + personal-infra aliases live in the
# private overlay, not here.

alias aliases='grep -E "^\s*alias" "$XDG_CONFIG_HOME/shell/conf.d/20-aliases.sh"'

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias sudo='sudo '                 # let the next word be alias-expanded after sudo

# Shortcuts
alias s="cd ~/Source"
alias g="git"
alias b="bundle "
alias t="task"
alias vim="nvim"
alias vimq="nvim -u NONE"
alias mux="tmuxinator"
alias fuck="tmuxinator"
alias timestamp='date +"%Y%m%d%H%M%S"'
has neomutt && alias mutt='neomutt'   # neomutt is the maintained fork; keep the muscle memory

# git
alias gs='git s'
alias gds='git diff --stat'
alias gpom='git push origin master'
alias gfo='git fetch origin'
alias gpo='git push origin'
alias gm='git merge'
alias gc='git commit'
alias gca='git commit -a'
alias ga='git add'
alias sb='git checkout'
alias fixup='git rebase -i HEAD~2'

# Listing — eza when present, else coreutils ls with color.
if has eza; then
    alias ls='eza --group-directories-first'
    alias l='eza -l  --git --group-directories-first'
    alias ll='eza -l --git --group-directories-first'
    alias la='eza -la --git --group-directories-first'
    alias lsd='eza -lD'
    alias lt='eza --tree --level=2'
else
    _ls="$(gnu ls)"; alias ls="$_ls -F --color=auto"; unset _ls
    alias l='ls -l'
    alias ll='ls -Fl'
    alias la='ls -Fla'
    alias lsd='ls -Fl | grep "^d"'
fi
alias sl=ls

# Trim trailing newline and copy to the clipboard (platform `clip` wrapper)
alias c="tr -d '\n' | clip"

# Misc utilities
alias map="xargs -n1"
alias nogrep='grep -v grep'
alias cuts="cut -f ' '"
alias freqs="awk '{ for (i = 1; i <= NF; i++) freq[\$i]++ } END { for (word in freq) printf \"%d\t%s\n\", freq[word], word }'"
alias sum="awk '{s+=\$1} END {print s}'"
alias rot13='tr a-zA-Z n-za-mN-ZA-M'
alias badge="tput bel"
alias biggestfiles="du -a . | sort -n -r | head -n 20"
alias ducks="du -cks * | sort -rn | head"
alias where="hostname"
alias why="echo because..."
alias fixpaste="printf '\e[?2004l'"
alias disable-bracketed-paste="printf '\e[?2004l'"

# Public IP (dig is cross-platform)
has dig && alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Coreutils niceties that BSD/macOS lack (no-op wherever the real tool exists)
has hd      || alias hd="hexdump -C"
has md5sum  || alias md5sum="md5"
has sha1sum || { alias sha1sum="shasum"; alias sha256sum="shasum -a 256"; alias sha512sum="shasum -a 512"; }
has free    || alias free="top -l 1 | head -n 10 | grep PhysMem"
has ldd     || alias ldd="otool -L"

# URL-encode (python3)
has python3 && alias urlencode='python3 -c "import sys,urllib.parse as u; print(u.quote_plus(sys.argv[1]))"'

# GPG: list the recipients of an encrypted message
has gpg && alias list-recipients="gpg --batch --decrypt --list-only --status-fd 1 2>/dev/null | awk '/^\[GNUPG:\] ENC_TO / { print \$3 }' | while read key; do (gpg --list-keys \$key >/dev/null 2>&1 && gpg --list-keys \$key) || echo \"-- unknown key ID: \$key\"; done"

# Convert a batch of flac files to mp3
has ffmpeg  && alias flac2mp3='for f in *.flac; do </dev/null ffmpeg -i "$f" -qscale:a 0 "${f/%flac/mp3}"; done'

# --- macOS only -------------------------------------------------------------
if is_mac; then
    alias o="open"
    alias oo="open ."
    alias update='sudo softwareupdate -i -a; brew update && brew upgrade'
    alias localip="echo -n 'en0: '; ipconfig getifaddr en0; echo -n 'en1: '; ipconfig getifaddr en1; echo ''"
    alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"
    alias routerip="netstat -rn | grep default | tr -s ' ' | cut -d ' ' -f 2"
    alias flush="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
    alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
    alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
    alias spotoff="sudo mdutil -a -i off"
    alias spoton="sudo mdutil -a -i on"
    alias plistbuddy="/usr/libexec/PlistBuddy"
    alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume 7'"
    alias obscuro='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'  # lock screen
fi

# --- linux only -------------------------------------------------------------
if is_linux; then
    has xdg-open && { alias o="xdg-open"; alias oo="xdg-open ."; }
    if   has apt-get; then alias update='sudo apt update && sudo apt dist-upgrade'
    elif has dnf;     then alias update='sudo dnf upgrade --refresh'; fi
fi
