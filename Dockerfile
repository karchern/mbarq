FROM continuumio/miniconda3:latest

# Basic tools
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Hard override any global conda configuration:
# Only conda-forge and bioconda; no defaults.
# This writes a system-level .condarc that will be picked up by all conda calls.
RUN mkdir -p /etc/conda && \
    printf "channels:\n  - conda-forge\n  - bioconda\nchannel_priority: strict\n" > /etc/conda/.condarc

# Also clear any user-level channels and re-add what we want
RUN conda config --remove channels defaults && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --set channel_priority strict && \
    conda config --show channels

# Install mamba from conda-forge (now without defaults)
RUN conda install -y mamba -n base -c conda-forge && \
    conda clean -afy

# Clone mbarq
WORKDIR /opt
RUN git clone https://github.com/MicrobiologyETHZ/mbarq.git
WORKDIR /opt/mbarq

# Use bash so 'conda' works as expected in RUN steps
SHELL ["/bin/bash", "-c"]

# Create env and install mbarq
RUN mamba env create -f mbarq_environment.yaml && \
    source activate mbarq && \
    pip install -e . && \
    conda clean -afy

# Make the mbarq env default on PATH
ENV PATH=/opt/conda/envs/mbarq/bin:${PATH}

# Sanity check: fail build if mbarq is not callable
RUN mbarq --help >/dev/null


ENTRYPOINT ["/bin/bash"]
CMD []
