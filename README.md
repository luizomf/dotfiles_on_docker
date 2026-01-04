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
git clone https://github.com/luizomf/dotfiles_on_docker.git dotfiles_on_docker
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

## Permissions

When the directory `project` is created by Docker, you may end up with your host
user or `root` owning it. That means you won't be able to do anything with that
directory.

To fix that, you can match you `$USER` id with the user inside docker. You can
even match the username if you wish. You just have to change the `.env` file,
delete volume and rebuild.

Let me show you how you can do it:

```sh
# Find your user ID
id
# In the VM I'm testing, the username is `luizotavio`, the group is `luizotavio`,
# and both UID and GID are 1001.
# uid=1001(luizotavio) gid=1001(luizotavio)...
# Right, go to `.env` and change the values:
# The current values are:
DEV_USER=dubuntu
DEV_UID=1010
DEV_GID=1010
# The new values are:
DEV_USER=luizotavio
DEV_UID=1001
DEV_GID=1001

# Now lets stop the container (if it is running)
docker compose down
# And delete the volume
docker volume rm user_home_dubuntu
# If you wish to check first: docker volume ls
# Now, just to make sure it will work, lets fix the
# permissions.
# If you deleted the `projects` folder
mkdir -p projects
# If the current user is `root`, you will need sudo here
sudo chown -R $USER:$USER projects
sudo chmod -R 755 projects
# Now re-build
just upbuildexec

# Since we did not delete the image, it may be way faster
# Now, test it:
touch ~/projects/deleteme
echo 123 > ~/projects/deleteme
cat ~/projects/deleteme
123 # <- result
rm ~/projects/deleteme

# That worked here 🫶
```

Hope this helps!

---
