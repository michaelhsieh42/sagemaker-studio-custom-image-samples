# This project is licensed under the terms of the Modified BSD License (also known as New or Revised or 3-Clause BSD), as follows:

#    Copyright (c) 2001-2015, IPython Development Team
#    Copyright (c) 2015-, Jupyter Development Team

# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

# Neither the name of the Jupyter Development Team nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
FROM public.ecr.aws/docker/library/python:3.7

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"

# Setup the "sagemaker-user" user with root privileges.
RUN \
    apt-get update && \
    apt-get install -y sudo && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    echo "${NB_USER}    ALL=(ALL)    NOPASSWD:    ALL" >> /etc/sudoers && \
    # Prevent apt-get cache from being persisted to this layer.
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Make the default shell bash (vs "sh") for a better Jupyter terminal UX
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    HOME=/home/$NB_USER \
    MINICONDA_VERSION=4.11.0 \
    CONDA_VERSION=4.11.0 \
    MINICONDA_MD5=7675bd23411179956bcc4692f16ef27d \
    CONDA_DIR=/opt/conda \
    PATH=$CONDA_DIR/bin:${PATH}

# Heavily inspired from https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile

USER root

# R system library pre-requisites # --no-install-recommends
RUN apt-get update && \
    apt-get install -y \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p $CONDA_DIR && \
    chown -R $NB_USER:$NB_GID $CONDA_DIR && \
    # Fix for devtools https://github.com/conda-forge/r-devtools-feedstock/issues/4
    ln -s /bin/tar /bin/gtar

USER $NB_UID

ENV PATH=$CONDA_DIR/bin:${PATH}

# Install conda via Miniconda
RUN cd /tmp && \
    curl --silent --show-error --output miniconda-installer.sh https://repo.anaconda.com/miniconda/Miniconda3-py37_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *miniconda-installer.sh" | md5sum -c - && \
    /bin/bash miniconda-installer.sh -f -b -p $CONDA_DIR && \
    rm miniconda-installer.sh && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda install --quiet --yes conda="${CONDA_VERSION%.*}.*" && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn


# R packages and Python packages that are usable via "reticulate".
RUN conda install --quiet --yes \
    'r-base=4.1.2' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidyverse' \
    'unixodbc' \
    'r-tidymodels' \
    'r-reticulate' \
    r-essentials \
    r-fable \
    r-fabletools \
    r-ggplot2 \
    r-dplyr \
    r-stringr \
    r-tsibble \
    r-feasts \
    r-urca \
    r-readr \
    r-remotes \
    r-sodium \
    r-jsonlite \
    r-e1071 \
    r-mlbench \
    r-gbm \
    && \
    pip install --quiet --no-cache-dir \
    'boto3>1.0<2.0' \
    'sagemaker>2.0<3.0' && \
    conda clean --all -f -y

WORKDIR $HOME
USER $NB_UID