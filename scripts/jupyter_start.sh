#!/bin/bash

if [[ $JUPYTER_PASSWORD ]]; then
    echo "Jupyter password is set"
else
    echo "Jupyter password is not set...generating one"
    # generate a uuid to use as password
    JUPYTER_PASSWORD=$(uuidgen) 
    echo "Jupyter password: $JUPYTER_PASSWORD"
fi

echo "Jupyter password: $JUPYTER_PASSWORD"

jupyter lab --allow-root --no-browser --port=8888 --ip=* --FileContentsManager.delete_to_trash=False --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
