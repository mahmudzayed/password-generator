## Base image from: https://hub.docker.com/_/python
FROM python:3.12-slim-bookworm

ENV APP_USER=appuser \
    APP_DIR=/app

WORKDIR ${APP_DIR}

COPY --chmod=0600 ./src/requirements.txt .

## Create app user, set ownerships
RUN groupadd --system ${APP_USER} && \
    useradd --system --gid ${APP_USER} --create-home --home-dir ${APP_DIR} --comment "Appliction User" ${APP_USER} && \
    chown -R ${APP_USER}:${APP_USER} ${APP_DIR}

## Install app prerequisites
RUN pip install -r requirements.txt

## Copy app source code(s)
COPY --chown=${APP_USER}:${APP_USER} --chmod=0700 ./src/main.py app.py

USER ${APP_USER}

CMD flask run --host 0.0.0.0