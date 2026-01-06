set dotenv-load := true

env_filepath := '.env'
container := 'ubuntu_local'
dockerfile := 'Dockerfile'
compose_file := 'compose.yaml'

# List just recipes
default:
  just -l

# docker alias {{ *ARGS }}
_d *ARGS:
  docker {{ ARGS }}

# docker compose {{ *ARGS }}
_dc *ARGS:
  just _d compose \
    --env-file {{ env_filepath }} \
    -f {{ compose_file }} \
    {{ ARGS }}

# docker compose up -d {{ *ARGS }}
up *ARGS:
  just _dc up -d {{ ARGS }}

# docker compose down
down:
  just _dc down

# docker compose run --rm {{ *ARGS }}
_dcr *ARGS:
  just _dc run  \
    -e HOST_CURR_DIR="{{ `pwd` }}" \
    --rm \
    {{ ARGS }}

# docker compose exec {{ *ARGS }}
_dce *ARGS:
  just _dc exec \
    -e HOST_CURR_DIR="{{ `pwd` }}" \
    {{ ARGS }}

# docker compose build {{ *ARGS }}
build *ARGS:
  just _dc build {{ ARGS }}

# docker compose up -d --build --force-recreate --remove-orphans {{ *ARGS }}
upbuild *ARGS:
  just _dc up -d --build --force-recreate --remove-orphans {{ ARGS }}

# docker compose up -d --build --force-recreate --remove-orphans {{ *ARGS }}
upbuildexec *ARGS: down
  just _dc up -d --build --force-recreate --remove-orphans {{ ARGS }}
  just exec

# docker compose run -u root -it {{ container }} /bin/bash {{ *ARGS }}
runroot *ARGS:
  just _dcr -u root -it {{ container }} /bin/bash {{ ARGS }}

# docker compose exec -u root -it {{ container }} /bin/bash {{ *ARGS }}
execroot *ARGS: up && down
  just _dce -u root -it {{ container }} /bin/bash {{ ARGS }}

# docker compose run -it {{ container }} {{ *ARGS }}
run *ARGS:
  just _dcr -it {{ container }} {{ ARGS }}

# docker compose exec -it {{ container }} /bin/zsh {{ *ARGS }}
exec *ARGS: up && down
  just _dce -it {{ container }} /bin/zsh {{ ARGS }}

# 🚨 REMOVES EVERYTHING AND BUILD FROM SCRATCH
nukebuild: nukeall
  just upbuildexec

# 🚨 REMOVES ALL VOLUMES AND RE-BUILD
nukevolumesbuild: nukevolumes
  just upbuildexec

# 🚨 THIS REMOVES EVERYTHING POSSIBLE (EVEN YOUR VOLUMES)
nukeall: down
  # Stop & remove all containers
  docker rm -f $(docker ps -aq) 2>/dev/null || true

  # Remove all images
  docker rmi -f $(docker images -aq) 2>/dev/null || true

  # Remove all volumes (THIS deletes persisted data)
  docker volume rm -f $(docker volume ls -q) 2>/dev/null || true

  # Remove all non-default networks
  docker network prune -f

  # Remove build cache (BuildKit)
  docker builder prune -af

  # Remove everything unused (extra safety net)
  docker system prune -af

# 🚨 THIS REMOVES ALL YOUR VOLUMES
nukevolumes: down
  # Remove all volumes (THIS deletes persisted data)
  docker volume rm -f $(docker volume ls -q) 2>/dev/null || true

# 🚨 THIS REMOVES ALL YOUR IMAGES
nukeimages: down
  # Remove all images
  docker rmi -f $(docker images -aq) 2>/dev/null || true

# 🚨 THIS REMOVES ALL CONTAINERS
nukecontainers: down
  # Stop & remove all containers
  docker rm -f $(docker ps -aq) 2>/dev/null || true
