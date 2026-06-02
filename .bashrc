if [ -f /opt/homebrew/bin/brew ]; then
  HOMEBREW_EXE="/opt/homebrew/bin/brew"
elif [ -f /usr/local/bin/brew ]; then
  HOMEBREW_EXE="/usr/local/bin/brew"
else
  HOMEBREW_EXE=""
fi

eval "$("$HOMEBREW_EXE" shellenv)"
[ -n "$PS1" ] && source ~/.bash_profile

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# pnpm
export PNPM_HOME="/Users/jenner/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
