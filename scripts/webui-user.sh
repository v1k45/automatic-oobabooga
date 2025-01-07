# #!/bin/bash
#########################################################
# Uncomment and change the variables below to your need:#
#########################################################

# Install directory without trailing slash
install_dir="/workspace"

# Name of the subdirectory
#clone_dir="stable-diffusion-webui"

# Commandline arguments for webui.py, for example: export COMMANDLINE_ARGS="--medvram --opt-split-attention"
#export COMMANDLINE_ARGS="--port 3000 --api --xformers --skip-install --listen --enable-insecure-extension-access"

if [[ $AUTOMATIC1111_CLI_ARGS ]]; then
    export COMMANDLINE_ARGS="$AUTOMATIC1111_CLI_ARGS"
else
    eval $(python /scripts/generate_auth.py --env)
    automatic_auth_args="--gradio-auth=$AUTOMATIC_UI_USERNAME:$AUTOMATIC_UI_PASSWORD --api-auth=$AUTOMATIC_API_KEY"
    automatic_extra_args="${AUTOMATIC_EXTRA_ARGS:-}"
    export COMMANDLINE_ARGS="--port 3000 --api $automatic_auth_args --xformers --skip-install --listen --enable-insecure-extension-access $automatic_extra_args"
fi
#export XFORMERS_PACKAGE="xformers==0.0.17.dev447"

# python3 executable
#python_cmd="python3"

# git executable
#export GIT="git"

# python3 venv without trailing slash (defaults to ${install_dir}/${clone_dir}/venv)
venv_dir="/venv/automatic"

# script to launch to start the app
#export LAUNCH_SCRIPT="launch.py"

# install command for torch
# export TORCH_COMMAND="pip install torch"

# Requirements file to use for stable-diffusion-webui
#export REQS_FILE="./extensions/sd_dreambooth_extension/requirements.txt"

# Fixed git repos
#export K_DIFFUSION_PACKAGE=""
#export GFPGAN_PACKAGE=""

# Fixed git commits
#export STABLE_DIFFUSION_COMMIT_HASH=""
#export TAMING_TRANSFORMERS_COMMIT_HASH=""
#export CODEFORMER_COMMIT_HASH=""
#export BLIP_COMMIT_HASH=""

# Uncomment to enable accelerated launch
# export ACCELERATE="True"

###########################################
