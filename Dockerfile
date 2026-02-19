FROM continuumio/miniconda3:latest

# Basic tools
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Use conda from base image
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Configure channels: drop defaults, add conda-forge and bioconda
RUN conda config --remove channels defaults && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --set channel_priority strict

# Install mamba in base env
# RUN conda install -y mamba -n base -c conda-forge && \
#     conda clean -afy

# Clone mbarq
WORKDIR /opt
RUN git clone https://github.com/MicrobiologyETHZ/mbarq.git
WORKDIR /opt/mbarq

# Use bash so 'conda' is available
SHELL ["/bin/bash", "-c"]

# Create env, install mbarq
RUN conda env create -f mbarq_environment.yaml

RUN source activate mbarq && \
    pip install -e . && \
    conda clean -afy

# Make mbarq env default on PATH
ENV PATH=/opt/conda/envs/mbarq/bin:${PATH}

# Sanity check
RUN mbarq --help >/dev/null

ENTRYPOINT ["/bin/bash"]
CMD []
