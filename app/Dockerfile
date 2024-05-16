## Base image from: https://hub.docker.com/_/python
FROM python:3.12-slim-bookworm

LABEL os="linux" \
    architecture="amd64" \
    maintainer="https://github.com/mahmudzayed"

ENV APP_USER=appuser \
    APP_DIR=/app

WORKDIR ${APP_DIR}

## Create app user, set ownerships
RUN groupadd --system ${APP_USER} && \
    useradd --system --gid ${APP_USER} --create-home --home-dir ${APP_DIR} --comment "Appliction User" ${APP_USER} && \
    chown -R ${APP_USER}:${APP_USER} ${APP_DIR}

## Copy dependency list file
COPY --chmod=0600 --chown=${APP_USER}:${APP_USER} ./src/requirements.txt .

## Install app dependencies
RUN pip install -r requirements.txt

## Copy app source code(s)
COPY --chown=${APP_USER}:${APP_USER} --chmod=0700 ./src/main.py app.py

## Drop to app user
USER ${APP_USER}

## Run app
CMD flask run --host 0.0.0.0