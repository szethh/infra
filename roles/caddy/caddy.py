import re
import yaml


host_map = {
    "100.102.225.136": "blokk",
    "100.125.191.94": "pve",
    "100.93.202.22": "proxy",
    "100.86.212.121": "homeassistant",
    "100.94.2.102": "oreonas",
}


def parse_caddyfile(caddyfile_content):
    pattern = r"(?P<subdomain>\S+)\s*{\s*reverse_proxy (?P<protocol>http|https)?://(?P<host>\S+):(?P<port>\d+)\s*}"
    matches = re.finditer(pattern, caddyfile_content, re.MULTILINE)

    rp_hosts = []
    for match in matches:
        subdomain = match.group("subdomain")
        host = match.group("host")
        port = match.group("port")
        protocol = match.group("protocol")

        rp_host = {
            "subdomain": subdomain,
            "host": host_map.get(host, host),
            "port": int(port),
        }

        if protocol and protocol != "http":
            rp_host["proto"] = protocol

        rp_hosts.append(rp_host)

    return {"rp_hosts": rp_hosts}


with open("Caddyfile.bak") as f:
    parsed_dict = parse_caddyfile(f.read())

yaml_content = yaml.dump(parsed_dict, sort_keys=False)

print(yaml_content)
