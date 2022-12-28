FROM python:3.9-slim-bullseye AS compile-image

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN python -m venv /app
# Make sure we use the virtualenv:
ENV PATH="/app/bin:$PATH"

RUN pip config --user set global.extra-index-url https://www.piwheels.org/simple

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -U pip && \
    python3 -m pip install --no-cache-dir -r requirements.txt

COPY . /app

FROM python:3.9-slim-bullseye

ARG REPO=whittlem/logwebtail

LABEL org.opencontainers.image.source https://github.com/${REPO}

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 1000 logwebtail && \
    useradd -r -u 1000 -g logwebtail logwebtail && \
    mkdir -p /app && \
    chown -R logwebtail:logwebtail /app

WORKDIR /app

USER logwebtail

# Make sure we use the virtualenv:
ENV PATH="/app/bin:$PATH"

COPY --chown=logwebtail:logwebtail --from=compile-image /app /app

# Pass parameters to the container run or mount your config.json into /app/
ENTRYPOINT [ "python3", "-u", "main.py" ]
