A template for [FastAPI](fastapi.md) apps.

# Project structure

For FastAPI projects, I currently (2022-2023) use the following structure:

```shell
.
|-- Dockerfile  # web app dockerfile
|-- Makefile  # commands for make
|-- README.md
|-- alembic.ini  # alembic migration file
|-- app  # source code
|   |-- api
|   |-- core
|   |-- db
|   |-- main.py  # entrypoint of web app.
|   |-- models
|   |-- schema
|   `-- services
|-- docker-compose.yml  # orchestrator of web app and db docker images
|-- poetry.lock
|-- pyproject.toml
|-- sql  # stores db related stuff, including the dockerfile and build sql file.
|   |-- db.Dockerfile
|   `-- init_db.sql
|-- tests
```

# Docker images

## web service

The web app container is configured as follows:

* python3.10. Update if needed.
* uses Poetry as dependency manager.
* create non-root user and activate it.

```dockerfile
FROM python:3.10-slim AS base
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends curl git build-essential \
    && apt-get autoremove -y
ENV POETRY_HOME="/opt/poetry"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
RUN curl -sSL https://install.python-poetry.org | python3 -

FROM base AS install

WORKDIR /home/code

# allow controlling the poetry installation of dependencies via external args
ARG INSTALL_ARGS="--no-root --no-dev"
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
COPY pyproject.toml poetry.lock ./

# install without virtualenv, since we are inside a container
RUN poetry config virtualenvs.create false \
    && poetry install $INSTALL_ARGS

# cleanup
RUN curl -sSL https://install.python-poetry.org | python3 - --uninstall
RUN apt-get purge -y curl git build-essential \
    && apt-get clean -y \
    && rm -rf /root/.cache \
    && rm -rf /var/apt/lists/* \
    && rm -rf /var/cache/apt/*

FROM install as app-image

COPY tests tests
COPY app app
COPY app/db/migrations alembic
COPY .env alembic.ini ./


# create a non-root user, assign dir ownership and switch to it, for sec purposes.
RUN addgroup --system --gid 1001 "app-user"
RUN adduser --system --uid 1001 "app-user"
RUN chown -R "app-user":"app-user" .
USER "app-user"
```

## db service

Separate [postgres](sql.md) container that executes a SQL file called `initdb`. See below for file.

```dockerfile
# pull base image
FROM postgres:15-alpine

# run init_db on init
ADD init_db.sql /docker-entrypoint-initdb.d

WORKDIR /home/db/code
```

`init_db.sql` - a file that is used when building the container. Creates a development db with a service account
user and assigns superuser privileges to the service account on the development db.

```sql
DROP DATABASE IF EXISTS devdb;
CREATE DATABASE devdb;
CREATE USER appdb_user with encrypted password 'appdb_user_pwd';
ALTER USER appdb_user WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE devdb TO appdb_user;
\connect devdb;
```
