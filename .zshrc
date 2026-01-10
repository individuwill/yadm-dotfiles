autoload -Uz compinit
compinit

source "$HOME/.myprofile"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(/opt/homebrew/bin/starship init zsh)"

