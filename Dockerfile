FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Base OS essentials (stable)
# 🚨 Never use this image in production.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    locales \
    tzdata \
    bash \
    zsh \
    openssl \
    curl \
    wget \
    git \
    openssh-client \
    openssh-server \
    file \
    less \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

RUN locale-gen en_US.UTF-8 ;
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# Core build toolchain (stable, heavy)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    pkg-config \
    pkgconf \
    llvm \
    cmake \
    ninja-build \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    gettext \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    lzma \
    libreadline-dev \
    libssl-dev \
    libffi-dev \
    libgdbm-dev \
    ncurses-term \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Python runtime + dev headers + venv tooling (stable-ish)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-venv \
    pipx \
    libsqlite3-dev \
    sqlite3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Shell/editor/terminal dev tools (stable-ish)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tmux \
    nano \
    bat \
    ripgrep \
    fd-find \
    watch \
    htop \
    tree \
    tree-sitter-cli \
    inotify-tools \
    p7zip \
    unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Lua/Tcl/Tk ecosystem (plugins often depend on these)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lua5.4 \
    liblua5.4-dev \
    luarocks \
    tcl \
    tk \
    tk-dev \
    tcl-dev \
    blt-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Media + fonts (stable)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ffmpeg \
    fonts-firacode \
    fonts-jetbrains-mono \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Networking / debugging tools (stable)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    iputils-ping \
    dnsutils \
    traceroute \
    iproute2 \
    net-tools \
    aria2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Docker inside docker? Let's test that out
# You have to mount:
# - /var/run/docker.sock:/var/run/docker.sock
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
     | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
     https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
     > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     docker-ce-cli docker-compose-plugin docker-buildx-plugin \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Discovery layer (changes often)
# Good for new packages.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  # Add new packages here first. Once you're happy with it, move
  # it to the above lines. This keeps the above packages in cache and
  # makes builds faster.
  shellcheck \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ;

# User creation (unchanged logic, but order improved)
ARG DEV_UID
ARG DEV_GID
ARG DEV_USER
ARG HOST_CURR_DIR
ARG HOME_PATH=/home/${DEV_USER}

ENV HOST_CURR_DIR=${HOST_CURR_DIR}

# Setup scripts (user, groups, etc)
# NEVER, EVER, EVER USE THIS IMAGE IN PROD.
COPY --chmod=o+x ./scripts /usr/local/bin
RUN setup_user ;

USER ${DEV_USER}
WORKDIR ${HOME_PATH}

ENV NONINTERACTIVE=1 \
    HOMEBREW_NO_ANALYTICS=1 \
    PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" ;

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
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
   ;

COPY --chown="${DEV_UID}":"${DEV_GID}" ./dotfiles dotfiles

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

ENV PYENV_ROOT="${HOME_PATH}/.pyenv"
ENV PATH="${HOME_PATH}/.pyenv/bin:${HOME_PATH}/.pyenv/shims:${PATH}"

RUN . ${HOME_PATH}/dotfiles/zsh/.zshrc \
  && eval "$(pyenv init --path)" \
  && uv tool install ruff \
  && uv tool install pyright \
  && ${HOME_PATH}/.pyenv/bin/pyenv install 3 \
  && ${HOME_PATH}/.pyenv/bin/pyenv global 3 \
  && ${HOME_PATH}/.pyenv/bin/pyenv exec pip install neovim \
  ;

RUN . ${HOME_PATH}/dotfiles/zsh/.zshrc \
  && nvm install --lts \
  && nvm install-latest-npm \
  && npm i -g prettier \
  && npm i -g neovim \
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

ENTRYPOINT ["docker_entrypoint"]
CMD ["/bin/zsh"]

