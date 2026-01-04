# My Development Environment for Docker

I tried to replicate this development environment precisely how I use it in
macOS.

I've been testing it for a few days and it's been working fine.

---

## How does it work?

I'm using Ubuntu 24.04 to run: `zsh`, `oh-my-zsh`, `tmux`, `nvim`, `vim`, and
lots of other applications. We are using a combination of: `Dockerfile`,
`compose.yaml` and `just` to make it easier to `build`, `start` and `stop`
containers.

So, if you what test it, make sure you have `Docker` and `just` installed.

In the docker compose file, I'm mapping 3 volumes to ensure my initial
configuration (my `dotfiles`) and data persistence after the build. I'm also
adding a `projects` folder, so you can work on your projects inside it.

- `./dotfiles` - Those are my real `dotfiles` with all things configured
- `./projects` - This is a directory you can use for your projects
- `user_home` - This directory is managed by docker. It is were your `$HOME`
  data will be persisted.

---

## How to build the image?

Make sure to have `docker` and `just` installed (and `git`, obviously).

- [Docker](https://www.docker.com/)
- [just](https://github.com/casey/just)

### Building and running

It is very simple. Just clone this repo and build the imagem. If you wish to see
all the `just` recipes, just run `just`.

```sh
git clone git@github.com:luizomf/dotfiles_on_docker.git dotfiles_on_docker
cd dotfiles_on_docker
# Copy the .env.example to the real .env
cp .env.example .env
# This just recipe will execute those commands:
# docker compose --env-file .env -f compose.yaml down
# docker compose --env-file .env -f compose.yaml up -d --build --force-recreate --remove-orphans
# docker compose --env-file .env -f compose.yaml up -d
# docker compose --env-file .env -f compose.yaml exec -it ubuntu_local /bin/zsh
just upbuildexec # It takes about 5 minutes to build

# If everything is OK, you'll end-up in the container.
# Just `exit` to leave
```

After this initial build, you can just run `just exec` to enter whenever you
want.

---
