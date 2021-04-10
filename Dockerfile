FROM ubuntu:xenial-20201030

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    autoconf \
                    build-essential \
                    bzip2 \
                    ca-certificates \
                    curl \
                    cython3 \
                    git \
                    libtool \
                    lsb-release \
                    pkg-config \
                    xvfb \
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

# Installing and setting up miniconda
RUN curl -sSLO https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    bash Miniconda3-4.5.11-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-4.5.11-Linux-x86_64.sh

# Set CPATH for packages relying on compiled libs (e.g. indexed_gzip)
ENV PATH="/usr/local/miniconda/bin:$PATH" \
    CPATH="/usr/local/miniconda/include/:$CPATH" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PYTHONNOUSERSITE=1

# Installing precomputed python packages
RUN conda install -y -c anaconda -c conda-forge \
                     python=3.7.1 \
                     attr \
                     dipy \
                     eddymotion=0.1.2 \
                     jupyterlab \
                     jupytext \
                     nibabel \
                     nilearn \
                     nitransforms \
                     niworkflows \
                     libxml2=2.9.8 \
                     libxslt=1.1.32 \
                     matplotlib=2.2 \
                     numpy=1.20 \
                     pandoc=2.11 \
                     pip=20.3 \
                     setuptools=51.1 \
                     zlib; sync && \
    chmod -R a+rX /usr/local/miniconda; sync && \
    chmod +x /usr/local/miniconda/bin/*; sync && \
    conda build purge-all; sync && \
    conda clean -tipsy && sync

# Precaching fonts, set 'Agg' as default backend for matplotlib
RUN python -c "from matplotlib import font_manager" && \
    sed -i 's/\(backend *: \).*$/\1Agg/g' $( python -c "import matplotlib; print(matplotlib.matplotlib_fname())" )

# Installing nipreps-book
COPY . $HOME/nipreps-book

# Convert MyST files to ipynb notebook
RUN cd /$HOME/nipreps-book/docs/head-motion && \
    jupytext --to notebook head-motion/*md && \
    mkdir ../notebooks && \
    mv *ipynb ../notebooks/

# Start Jupyter lab
CMD ["jupyter", "lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
