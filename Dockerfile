FROM ubuntu:24.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash zsh openssl tk tmux ninja-build ffmpeg libsqlite3-dev \
    python3-venv libtool-bin bat build-essential watch fd-find \
    pkg-config locales curl fonts-firacode file p7zip ripgrep \
    tcl-dev libtool llvm libreadline-dev lzma cmake pipx \
    luarocks tree-sitter-cli sqlite3 nano wget autoconf pkgconf \
    fonts-jetbrains-mono zlib1g-dev less blt-dev git libbz2-dev \
    automake liblzma-dev tzdata tcl tk-dev libgdbm-dev python3-dev \
    lua5.4 unzip tree htop liblua5.4-dev gettext python3 \
    libssl-dev ca-certificates aria2 openssh-client make openssh-server \
    libffi-dev ncurses-term inotify-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ;

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_UID
ARG DEV_GID
ARG DEV_USER

ARG HOME_PATH=/home/${DEV_USER}
ENV HOME=${HOME_PATH}

RUN locale-gen en_US.UTF-8 ;
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

RUN \
  mkdir -p ${HOME_PATH} \
  && chown -R ${DEV_UID}:${DEV_GID} ${HOME_PATH} \
  && groupadd --gid ${DEV_GID} ${DEV_USER} \
  && useradd -d ${HOME_PATH} --uid ${DEV_UID} --gid ${DEV_GID} --no-create-home --shell /bin/zsh ${DEV_USER} \
  && mkdir -p /home/linuxbrew/.linuxbrew \
  && chown -R ${DEV_UID}:${DEV_GID} /home/linuxbrew \
  ;

USER ${DEV_USER}
WORKDIR ${HOME_PATH}

ENV NONINTERACTIVE=1 \
    HOMEBREW_NO_ANALYTICS=1 \
    PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" ;

# Install new things here to avoid downloading all things above
RUN brew install neovim vim fzf bat \
  && brew cleanup --prune=all ;

ENV ZSH_CUSTOM "${HOME_PATH}/.oh-my-zsh/custom"
RUN /bin/sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  "" --unattended \
  && git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ;

ENV LAZY_PATH "${HOME_PATH}/.local/share/nvim/lazy/lazy.nvim"
RUN git clone https://github.com/folke/lazy.nvim.git --filter=blob:none "$LAZY_PATH" ;

RUN git clone https://github.com/tmux-plugins/tpm "${HOME_PATH}/.tmux/plugins/tpm" ;
RUN curl -fsSL https://pyenv.run | bash ;
RUN curl -LsSf https://astral.sh/uv/install.sh | sh ;
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash ;
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ;

COPY dotfiles dotfiles

RUN mkdir -p "${HOME_PATH}/.config" \
  && ln -sfn "${HOME_PATH}/dotfiles/zsh/.zshrc" "${HOME_PATH}/.zshrc" \
  && ln -sfn "${HOME_PATH}/dotfiles/zsh/.zprofile" "${HOME_PATH}/.zprofile" \
  && ln -sfn "${HOME_PATH}/dotfiles/zsh/config/omtheme.zsh-theme" "${ZSH_CUSTOM}/themes/omtheme.zsh-theme" \
  && ln -sfn "${HOME_PATH}/dotfiles/git/.gitconfig" "${HOME_PATH}/.gitconfig" \
  && ln -sfn "${HOME_PATH}/dotfiles/tmux/.tmux.conf" "${HOME_PATH}/.tmux.conf" \
  && ln -sfn "${HOME_PATH}/dotfiles/vim/.vimrc" "${HOME_PATH}/.vimrc" \
  && ln -sfn "${HOME_PATH}/dotfiles/nvim" "${HOME_PATH}/.config/nvim" \
  && ln -sfn "${HOME_PATH}/dotfiles/zsh/config/omtheme.zsh-theme" "${ZSH_CUSTOM}/themes/omtheme.zsh-theme" \
  ;

RUN . ${HOME_PATH}/.zshrc \
  && nvm install --lts \
  && nvm install-latest-npm \
  && npm i -g prettier \
  && uv tool install ruff \
  && uv tool install pyright \
  && .pyenv/bin/pyenv install 3 \
  && .pyenv/bin/pyenv global 3 \
  ;

RUN vim +PlugInstall +qall >/dev/null 2>&1 \
  && nvim --headless "+Lazy sync" +qa \
  && nvim --headless "+MasonUpdate" +qa \
  && nvim --headless "+MasonInstallAll" +qa \
  && nvim --headless "+MasonInstall stylua" +qa \
  && tmux start-server \
  && tmux new-session -d \
  && "${HOME_PATH}/.tmux/plugins/tpm/bin/install_plugins" \
  && tmux kill-server \
  ;

RUN . ${HOME_PATH}/.zshrc \
  && npm i -g prettier \
  && npm i -g neovim \
  && .pyenv/bin/pyenv exec pip install neovim \
  ;

ENTRYPOINT []
CMD ["/bin/zsh"]

