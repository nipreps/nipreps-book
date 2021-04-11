FROM jupyter/base-notebook:lab-3.0.12

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

# Installing ANTs 2.3.3 (NeuroDocker build)
# Note: the URL says 2.3.4 but it is actually 2.3.3
ENV ANTSPATH=/usr/lib/ants
RUN mkdir -p $ANTSPATH && \
    curl -sSL "https://dl.dropbox.com/s/gwf51ykkk5bifyj/ants-Linux-centos6_x86_64-v2.3.4.tar.gz" \
    | tar -xzC $ANTSPATH --strip-components 1
ENV PATH=$ANTSPATH:$PATH

# Installing precomputed python packages
RUN conda install -y \
                  attr \
                  dipy \
                  eddymotion=0.1.2 \
                  jupyterlab \
                  jupytext \
                  nibabel \
                  nilearn \
                  nitransforms \
                  niworkflows \
                  matplotlib=2.2 \
                  numpy=1.20 \
                  pip=20.3 \
                  requests \
                  setuptools=51.1 \
                  zlib; sync && \
    conda build purge-all; sync && \
    conda clean -tipsy && sync

# Installing nipreps-book
COPY ../ $HOME/nipreps-book

# Start Jupyter lab
CMD jupyter lab --port=8888 --no-browser --ip=0.0.0.0 --allow-root
