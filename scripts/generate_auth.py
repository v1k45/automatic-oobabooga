#!/usr/bin/env python3
import argparse
import uuid
import os
import json
import sys

file_path = "/workspace/.auth.json"

def generate_auth():
    """
    Generate auth keys for the automatic and oobabooga services.
    The keys are stored in a file at /workspace/.auth.json
    """
    default_username = "autobooga"
    config = {
        "AUTOMATIC_UI_USERNAME": default_username,
        "AUTOMATIC_UI_PASSWORD": uuid_hex(),
        "AUTOMATIC_API_KEY": default_username + ":" + uuid_hex(),
        "OOBABOOGA_UI_USERNAME": default_username,
        "OOBABOOGA_UI_PASSWORD": uuid_hex(),
        "OOBABOOGA_API_KEY": uuid_hex(),
        "CLOUDFLARE_TUNNEL_TOKEN": "",
    }

    # override config from config file
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            try:
                config.update(json.load(f))
            except json.JSONDecodeError:
                # malformed json is expected. it will be overwritten.
                pass

    # overwrite with env vars
    for key in config:
        if os.environ.get(key):
            config[key] = os.environ.get(key)
    
    # Finally, write the config to the file
    with open(file_path, "w") as f:
        f.write(json.dumps(config, indent=4))

    return config

def uuid_hex():
   return str(uuid.uuid4().hex)

def get_auth(key):
    config = generate_auth()
    if key in config:
        print(config[key])
    else:
        sys.exit(f"Key {key} not found")
    
def print_env():
    values = [f"{key}={value}" for key, value in generate_auth().items()]
    return print("\n".join(values))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate auth keys for the automatic and oobabooga services")
    parser.add_argument("--key", type=str, help="The key to get")
    parser.add_argument("--env", action="store_true", help="Print all keys as environment variables")

    args = parser.parse_args()

    if args.key:
        get_auth(args.key)
    else:
        print_env()
