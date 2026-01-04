#!/usr/bin/env zsh

# Maybe you prefer to run this using entrypoint
# vim -Es +PlugInstall +qall >/dev/null 2>&1 # DOES NOT WORK
# vim +PlugInstall +qall >/dev/null 2>&1 # DOES WORK
# nvim --headless "+Lazy sync" +qa
# nvim --headless "+MasonUpdate" +qa
# nvim --headless "+MasonInstallAll" +qa

exec "${@}"
