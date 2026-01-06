# My Docker-Based Development Environment

> 🚨 **WARNING** This image is **not intended for production use**. It's a
> **developer environment** and intentionally includes unsafe defaults for
> convenience (sudo, sudoers, etc).

This repository contains my personal development environment, running on Ubuntu
inside Docker. The goal is to replicate how I actually work on macOS, but in a
clean, reproducible Linux setup.

I’ve been using this setup daily for a few days now, and it's been working well.

---

## How does it work?

The environment is based on **Ubuntu 24.04** and includes tools I use every day,
such as:

- `zsh` + `oh-my-zsh`
- `tmux`
- `neovim` and `vim`
- and many other CLI tools

The setup uses a combination of:

- `Dockerfile`
- `compose.yaml`
- `just`

To make it easy to **build**, **start**, **stop**, and **enter** the container.

If you want to try it yourself, make sure you have these installed:

- [Docker](https://www.docker.com/)
- [just](https://github.com/casey/just)

---

## Volumes and persistence

The Docker Compose file maps three volumes/directories to keep configuration and
data persistent across rebuilds:

- `./dotfiles` My real dotfiles, exactly as I use them.
- `./projects` A directory for your own projects. This is where you should work.
- `user_home` (Docker volume) Managed by Docker. This is where your `$HOME` data
  is persisted.

---

## Building and running the environment

Clone the repository and build the image. If you want to see all available
`just` recipes, just run `just`.

```sh
git clone https://github.com/luizomf/dotfiles_on_docker.git dotfiles_on_docker
cd dotfiles_on_docker

# Copy the example environment file
cp .env.example .env

# This recipe runs the following commands internally:
# docker compose --env-file .env -f compose.yaml down
# docker compose --env-file .env -f compose.yaml up -d --build --force-recreate --remove-orphans
# docker compose --env-file .env -f compose.yaml up -d
# docker compose --env-file .env -f compose.yaml exec -it ubuntu_local /bin/zsh
just upbuildexec  # First build takes ~5 minutes
```

If everything goes well, you'll end up inside the container. Type `exit` to
leave.

After the first build, you can simply run:

```sh
just exec
```

To enter the environment whenever you want.

---

## Permissions (important)

When the `projects` directory is created by Docker, it may end up owned by
`root` or by a different user than your host user. When that happens, you won’t
be able to write to it normally.

To fix this, you can **match your host UID/GID with the user inside the
container**. You can even match the username if you want.

This requires:

- editing the `.env` file
- deleting the Docker volume
- rebuilding the container

### Example

```sh
# Check your host user IDs
id
```

Example output (from a VM I tested):

```text
uid=1001(luizotavio) gid=1001(luizotavio)
```

Edit `.env`.

Current values:

```env
DEV_USER=dubuntu
DEV_UID=1010
DEV_GID=1010
```

Updated values:

```env
DEV_USER=luizotavio
DEV_UID=1001
DEV_GID=1001
```

Now stop the container and remove the volume:

```sh
docker compose down
docker volume rm user_home_dubuntu
# (check volumes with: docker volume ls)
```

Fix permissions on the `projects` directory if needed:

```sh
mkdir -p projects
sudo chown -R $USER:$USER projects
sudo chmod -R 755 projects
```

Rebuild:

```sh
just upbuildexec
```

Test it:

```sh
touch ~/projects/deleteme
echo 123 > ~/projects/deleteme
cat ~/projects/deleteme
rm ~/projects/deleteme
```

If you see `123`, everything is working.

---

## Fonts

If you have issues with the `tmux` theme or icons, make sure you’re using a
compatible font:

- [powerline/fonts](https://github.com/powerline/fonts)
- I personally use [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

---

Hope this helps!

---
