FROM mambaorg/micromamba:latest

RUN micromamba install -y -n base -c conda-forge git && \
    micromamba clean --all --yes

# Install mamba from conda-forge (now without defaults)
RUN micromamba install -y mamba -n base -c conda-forge && \
    micromamba clean -afy

# Clone mbarq
WORKDIR /opt
RUN git clone https://github.com/MicrobiologyETHZ/mbarq.git
WORKDIR /opt/mbarq

# Use bash so 'conda' works as expected in RUN steps
SHELL ["/bin/bash", "-c"]

# Create env and install mbarq
RUN micromamba env create -f mbarq_environment.yaml && \
    source activate mbarq && \
    pip install -e . && \
    conda clean -afy

# Make the mbarq env default on PATH
ENV PATH=/opt/conda/envs/mbarq/bin:${PATH}

# Sanity check: fail build if mbarq is not callable
RUN mbarq --help >/dev/null


ENTRYPOINT ["/bin/bash"]
CMD []
