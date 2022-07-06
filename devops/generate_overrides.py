import docker
import json
import base64
import subprocess
from kubernetes import client, config
from io import open
import requests
import os

NAMESPACE="reporting"
SERVICE_ACOUNT_NAME="gat-reporting-app"
CONFIG_MAP_FOR_APP="infra-gat-reporting-app"
CONFIG_MAP_WITH_VAULT_ADDR="vault"
CONFIG_MAP_WITH_URLS="urls"

REGISTRY_NAME="onelexcloudregistry.azurecr.io"
PIPELINE_CONTAINER="az-deploy-dev2-eastus:latest"
GEO="us"

def generate_kube_config():
  docker_client = docker.from_env()
  container_response = docker_client.containers.run(f"{REGISTRY_NAME}/lex-cloud/deploy/{PIPELINE_CONTAINER}", "python3 ./pipeline/config.py '{\"geo\": \"{GEO}\", \"provider\": \"azure\", \"namespace\": {\"name\": \"reporting\"}, \"apps\": [{\"id\": \"gat-reporting-app\", \"database\": \"create\"}]}'")
  kube_config = json.loads(container_response)['kube_config']
  decoded_kube_config = base64.b64decode(kube_config)
  with open("kube_config.yaml", "w+", newline="\r\n") as f:
    f.write(decoded_kube_config.decode('UTF-8'))

def get_k8s_client():
  config.load_kube_config(config_file="kube_config.yaml")
  return client.CoreV1Api()

def get_secret_name():
  sa = get_k8s_client().read_namespaced_service_account(name=SERVICE_ACOUNT_NAME, namespace=NAMESPACE)
  return sa.secrets[0].name

def get_jwt_token():
  secret_name = get_secret_name()
  secret = get_k8s_client().read_namespaced_secret(name=secret_name, namespace=NAMESPACE)
  return base64.b64decode(secret.data["token"])

def get_app_config():
  return get_k8s_client() \
    .read_namespaced_config_map(name=CONFIG_MAP_FOR_APP, namespace=NAMESPACE) \
    .data

def get_vault_addr_and_mountpoint():
  return get_k8s_client() \
    .read_namespaced_config_map(name=CONFIG_MAP_WITH_VAULT_ADDR, namespace=NAMESPACE) \
    .data
 
def get_app_urls():
  return get_k8s_client() \
    .read_namespaced_config_map(name=CONFIG_MAP_WITH_URLS, namespace=NAMESPACE) \
    .data

def get_vault_portal_login_token(args):
  url = f"{args['vault_addr']}/v1/auth/{args['mount_point']}/login"
  headers = {"Content-Type": "application/json"}
  data = json.dumps({"jwt": get_jwt_token().decode('UTF-8'), "role": args['vault-role']})

  resp = requests.post(url, data=data, headers=headers)
  return json.loads(resp.text)['auth']['client_token']

def generate_overrides_file(file_path, file_name, args):
  overrides_file = os.path.join(file_path, file_name)
  with open(overrides_file, "w+", newline="\r\n") as f:
    f.write(f"vault_addr: {args['vault_addr']}\n")
    f.write(f"vault_role: {args['vault-role']}\n")
    f.write(f"vault_mount_point: {args['mount_point']}\n")
    f.write(f"base_dns: {args['base_dns']}\n")
    f.write(f"idp_url: {args['idp_url']}\n")
    f.write(f"internal_reporting_url: {args['internal_reporting_url']}\n")
    f.write(f"reporting_url: {args['reporting_url']}\n")
    f.write(f"database_host: {args['database_host']}\n")
    f.write(f"database_name: {args['database_name']}\n")
    f.write(f"database_port: \"{args['database_port']}\"\n")
    f.write(f"vault_application_secret: {args['vault-application-secret']}\n")
    
def append_to_overrides_file(file_path, file_name, content):
  overrides_file = os.path.join(file_path, file_name)
  with open(overrides_file, "a", newline="\r\n") as f:
    f.write(content)

def get_environment_variables(args):
  env = args['vault-application-secret'].split("/")[0]
  content = ''
  if env.startswith("dev"):
    content = read_environment_variables("dev")
  elif env.startswith("qa"):
    content = read_environment_variables("qa")
  elif env.startswith("prod"):
    content = read_environment_variables("prod")
  else:
      print("unknown environment")
      raise
  return content

def read_environment_variables(env):
  env_file = os.path.join("environments", "%s.yaml" % env)
  if not os.path.exists(env_file):
    print(f"environments/{env}.yaml does not exist")
    raise
  return open(env_file, "r").read()

# Generate kube_config.yaml if needed
if not os.path.exists("kube_config.yaml"):
  generate_kube_config()

# Generate overrides file
args = {}
args.update( get_app_config() )
args.update( get_vault_addr_and_mountpoint() )
args.update( get_app_urls() )
generate_overrides_file(".", "overrides.yaml", args)

# Append environment variables to overrides
environment_variables = get_environment_variables(args)
append_to_overrides_file(".", "overrides.yaml", environment_variables)

# Print vault token and login url 
vault_portal_login_token = get_vault_portal_login_token(args)
print(f"vault-url: {args['vault_addr']}")
print(f"vault-token: {vault_portal_login_token}")