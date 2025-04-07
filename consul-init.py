import yaml
import requests
import sys
import os
import consul

# CONFIG: Set your Consul address
CONSUL_HOST = os.getenv("CONSUL_HOST", "127.0.0.1")
consul = consul.Consul(host=CONSUL_HOST)

def load_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def parse_leaf(data: dict, path: str):
    for key in data.keys():
        value = data[key]
        if isinstance(value, dict):
            if path == "":
                path = key
            else:
                path += f"/{key}"
            print(f"👣 Path: {path}")
            parse_leaf(value, path)
        else:
            full_key = f"{path}/{key}"
            print(f"✅ Set {full_key} = {value}")
            consul.kv.put(full_key, str(value))

def main(yaml_file):
    data = load_yaml(yaml_file)
    try:
        parse_leaf(data, "")
    except KeyError:
        print("❌ YAML file does not contain expected structure under 'infra.windows-ami'")
        sys.exit(1)

    # push_to_consul("infra/windows-ami", config)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python upload_consul_kv.py path/to/config.yaml")
        sys.exit(1)
    
    main(sys.argv[1])
