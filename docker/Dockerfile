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

USER $NB_UID

# Installing precomputed python packages
RUN conda install -y -c anaconda -c conda-forge \
                  attr \
                  dipy \
                  jupytext \
                  nibabel \
                  nilearn \
                  matplotlib=2.2 \
                  numpy=1.20 \
                  requests \
                  zlib && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install remaining python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir eddymotion nitransforms niworkflows

# Installing nipreps-book
COPY . $HOME/nipreps-book
