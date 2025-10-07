FROM ghcr.io/prefix-dev/pixi:0.53.0 AS build

USER root

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    ca-certificates \
                    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run post-link scripts during install, but use global to keep out of source tree
RUN pixi config set --global run-post-link-scripts insecure

# Install dependencies before the package itself to leverage caching
RUN mkdir /app
COPY pixi.lock pixi.toml /app
WORKDIR /app

RUN pixi install -e default --frozen
RUN pixi shell-hook -e default --as-is | grep -v PATH > /shell-hook.sh


FROM jupyter/base-notebook:x86_64-lab-4.0.7

USER root

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    curl \
                    dvipng \
                    texlive-fonts-recommended \
                    texlive-fonts-extra \
                    texlive-latex-extra \
                    cm-super && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --link --from=build /app/.pixi/envs/default /app/.pixi/envs/default
COPY --link --from=build /shell-hook.sh /shell-hook.sh
RUN cat /shell-hook.sh >> $HOME/.bashrc
ENV PATH="/app/.pixi/envs/default/bin:$PATH"

ENV NB_USER=jovyan \
    NB_GROUP=users \
    NB_UID=1000 \
    NB_GID=100 \
    HOME=/home/jovyan

RUN fix-permissions "/home/${NB_USER}"
# RUN chmod -R ${NB_USER}.${NB_GROUP} "/home/${NB_USER}"

USER ${NB_USER}

WORKDIR ${HOME}

COPY --chown=${NB_UID}:${NB_GID} . ${HOME}/nipreps-book