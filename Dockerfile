FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive
ENV SHELL=/bin/bash
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu

WORKDIR /workspace

# Set up shell and update packages
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies
RUN apt update --yes && \
    apt upgrade --yes && \
    apt install --yes --no-install-recommends \
    git openssh-server libglib2.0-0 libsm6 libgl1 libxrender1 libxext6 ffmpeg wget curl psmisc rsync vim bc nginx \
    pkg-config libffi-dev libcairo2 libcairo2-dev libgoogle-perftools4 libtcmalloc-minimal4 apt-transport-https \
    software-properties-common ca-certificates && \
    update-ca-certificates

# Install Python 3.10
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt install python3.10-dev python3.10-venv -y --no-install-recommends && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \python get-pip.py && \
    pip install -U --no-cache-dir pip

RUN mkdir /sd-models && mkdir /cn-models

# Create a virtual environments
RUN mkdir /venv
RUN python -m venv /venv/automatic && \
    source /venv/automatic/bin/activate && \
    pip install -U --no-cache-dir pip setuptools wheel
RUN python -m venv /venv/oobabooga && \
    source /venv/oobabooga/bin/activate && \
    pip install -U --no-cache-dir pip setuptools wheel

# Install JupyterLab globally
RUN pip install -U --no-cache-dir jupyterlab jupyterlab_widgets ipykernel ipywidgets

# Download repositories
RUN git clone -b v1.10.0 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git --depth=1 && \
    git clone -b v2.0 https://github.com/oobabooga/text-generation-webui.git --depth=1 && \
    git clone https://github.com/jjangga0214/sd-models-downloader.git --depth=1 /workspace/downloader && \
    # Install SD extensions
    cd stable-diffusion-webui && \
    git clone https://github.com/deforum-art/sd-webui-deforum --depth=1 extensions/deforum && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git --depth=1 extensions/sd-webui-controlnet && \
    git clone https://github.com/BlafKing/sd-civitai-browser-plus.git --depth=1 extensions/sd-civitai-browser-plus

# Install all dependencies
RUN cd stable-diffusion-webui && \
    source /venv/automatic/bin/activate && \
    pip install --no-cache-dir -U torch torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu118 && \
    pip install --no-cache-dir -r requirements_versions.txt && \
    python -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test && \
    cd /workspace/stable-diffusion-webui/extensions && \
    pip install --no-cache-dir basicsr && \
    # Install requirements for all extensions
    for d in */; do \
        cd $d && \
        pip install --no-cache-dir -r requirements.txt && \
        cd ..; \
    done && \
    # move to workspace
    mv /workspace/stable-diffusion-webui /stable-diffusion-webui

# Install Oobabooga Text Generation Web UI
RUN cd /workspace/text-generation-webui && \
    source /venv/oobabooga/bin/activate && \
    pip install --no-cache-dir -r requirements.txt && \
    mv /workspace/text-generation-webui /text-generation-webui

# Download Cloudflared for Tunneling
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
    # Add this repo to your apt repositories
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | tee /etc/apt/sources.list.d/cloudflared.list && \
    # install cloudflared
    apt-get update && apt-get install cloudflared

# Cleanup
RUN rm -rf /workspace/*

COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Start Scripts
COPY scripts/ /scripts

# Make scripts executable
RUN chmod +x /scripts/*.sh

EXPOSE 3000 4000 5000 8888 80
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/scripts/start.sh" ]
