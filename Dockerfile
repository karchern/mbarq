FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git wget bzip2 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda install -y mamba -n base -c conda-forge && \
    conda clean -afy

# Channel configuration
RUN conda config --remove channels defaults || true && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --set channel_priority strict

WORKDIR /opt
RUN git clone https://github.com/MicrobiologyETHZ/mbarq.git
WORKDIR /opt/mbarq

SHELL ["/bin/bash", "-c"]

RUN mamba env create -f mbarq_environment.yaml && \
    source activate mbarq && \
    pip install -e . && \
    conda clean -afy

ENV PATH=/opt/conda/envs/mbarq/bin:${PATH}

RUN mbarq --help >/dev/null

ENTRYPOINT ["/bin/bash"]
CMD []
