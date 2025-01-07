#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# Based on `https://github.com/runpod/containers/blob/95a5929f61605e0082fe619d12eace8e82675a37/container-template/start.sh`

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        log "${script_msg}"
        bash ${script_path}
    fi
}

# keep alive - keeps a given script running by restarting it if it exits
keep_alive() {
    local script_path=$1
    local script_msg=$2
    local retry_interval=$3

    log "Starting keep-alive for ${script_path}..."
    while true ; do
        log "${script_msg}"

        ${script_path} 2>&1 || {
            log "Script '${script_path}' exited with an error. Restarting in ${retry_interval} seconds..."
            sleep ${retry_interval}
            continue
        }
    done
}

# ---------------------------------------------------------------------------- #
#                            Setup Environment                                 #
# ---------------------------------------------------------------------------- #

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

         if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
            echo "RSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
            echo "DSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_dsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
            echo "ECDSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
            echo "ED25519 key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
        fi

        service ssh start

        echo "SSH host keys:"
        for key in /etc/ssh/*.pub; do
            echo "Key: $key"
            ssh-keygen -lf $key
        done
    fi
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

# ---------------------------------------------------------------------------- #
#                                Run scripts                                   #
# ---------------------------------------------------------------------------- #

start_jupyter() {
    keep_alive "/scripts/jupyter_start.sh" "Starting Jupyter Lab..." 5
}

start_automatic() {
    keep_alive "/scripts/automatic_start.sh" "Starting Automatic111 Stable Diffusion Web-UI..." 5
}

start_oobabooga() {
    keep_alive "/scripts/oobabooga_start.sh" "Starting Oobabooga Text Generation Web-UI..." 5
}

start_tunnel() {
    keep_alive "/scripts/cloudflare_tunnel_start.sh" "Starting Cloudflare Tunnel..." 5
}

start_nginx() {
    service nginx start
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #


execute_script "/scripts/pre_start.sh" "Running pre-start script..."
log "Pod Started"

# Setup environment
export_env_vars
setup_ssh

# Start services
log "Starting services..."
start_tunnel &
start_nginx
start_jupyter &
start_automatic &
start_oobabooga &

execute_script "/post_start.sh" "Running post-start script..."
log "Start script finished, pod is ready to use."

sleep infinity
