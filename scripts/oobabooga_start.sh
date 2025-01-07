#!/bin/bash

# Activate the virtual environment
source /venv/oobabooga/bin/activate

# Change to the webui directory
cd /workspace/text-generation-webui/

# Function to download the model
download_model() {
    if [[ -z $OOBABOOGA_DEFAULT_MODEL ]]; then
        echo "No default model specified. Skipping model download."
        return
    fi

    local download_args=$OOBABOOGA_DEFAULT_MODEL
    if [[ $OOBABOOGA_MODEL_FILE ]]; then
        download_args="$download_args --model-file=$OOBABOOGA_MODEL_FILE"
    fi

    python download-model.py $download_args 2>&1 || {
        echo "Failed to download model. Retrying with --clean."

        download_args="$download_args --clean"
        python download-model.py $download_args 2>&1 || {
            echo "Failed to download model. Continuing."
        }
    }
}

# Check if CLI arguments are provided
if [[ $OOBABOOGA_CLI_ARGS ]]; then
    ob_webui_args=$OOBABOOGA_CLI_ARGS
else
    # Generate authentication arguments
    eval $(python /scripts/generate_auth.py --env)
    ob_auth_args="--gradio-auth=$OOBABOOGA_UI_USERNAME:$OOBABOOGA_UI_PASSWORD --api-key=$OOBABOOGA_API_KEY"
    ob_extra_args="${OOBABOOGA_EXTRA_ARGS:-}"
    ob_webui_args="--listen --listen-port=4000 --api --api-port=5000 $ob_auth_args $ob_extra_args"
fi

# Download the model
download_model

# Start the server
python server.py $ob_webui_args
