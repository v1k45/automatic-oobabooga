# Sync Automatic1111 source and models to mounted workspace
echo "**** syncing stable diffusion to workspace, please wait ****"
rsync --remove-source-files -rlptDu --ignore-existing /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
cp /scripts/webui-user.sh /workspace/stable-diffusion-webui/webui-user.sh

# Sync Oobabooga source and models to mounted workspace
echo 'syncing oobabooga to workspace, please wait'
rsync --remove-source-files -rlptDu --ignore-existing /text-generation-webui/ /workspace/text-generation-webui/

