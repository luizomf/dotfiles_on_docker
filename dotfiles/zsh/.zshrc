#!/bin/sh
# vim: set filetype=sh :

# Isso aqui carrega todos os outros arquivos de config
source "${HOME}/dotfiles/zsh/config/use_this_to_load"

# bun completions
[ -s "/Users/luizotavio/.bun/_bun" ] && source "/Users/luizotavio/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"
