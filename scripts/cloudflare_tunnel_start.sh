#!/bin/bash

eval $(python /scripts/generate_auth.py --env)

if [[ $CLOUDFLARE_TUNNEL_TOKEN ]]; then
    echo "Cloudflare tunnel token is set - starting tunnel..."
    cloudflared tunnel run --token $CLOUDFLARE_TUNNEL_TOKEN
fi
