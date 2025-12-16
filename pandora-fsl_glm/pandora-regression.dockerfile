FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
      gawk \
      tar \
      dos2unix \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Install FSL
RUN conda create -y -p /opt/fsl \
      -c https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/ \
      -c conda-forge \
      fsl-melodic blas=*=*mkl \
    && conda clean -afy

# FSL env
ENV FSLDIR=/opt/fsl
ENV PATH=$FSLDIR/bin:$PATH

# Workdir
WORKDIR /work

# Runner
COPY pandora_regression.sh /usr/local/bin/pandora_regression.sh
RUN dos2unix /usr/local/bin/pandora_regression.sh && \ 
    chmod +x /usr/local/bin/pandora_regression.sh