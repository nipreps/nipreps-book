#!/bin/bash

apt-get update

apt-get install -y --no-install-recommends \
                curl
                dvipng \
                texlive-fonts-recommended \
                texlive-fonts-extra \
                texlive-latex-extra \
                cm-super
