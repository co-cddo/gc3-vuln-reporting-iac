import json

vdp_list = []


def get_vdps() -> list:
    global vdp_list
    if not vdp_list:
        with open("vdps.json") as v:
            vdp_list = json.load(v)
    return vdp_list


def get_default_vdp() -> dict:
    for v in get_vdps():
        if v.get("default", False):
            return v


def get_vdp_by_domain(domain: str, with_default: bool = False) -> dict:
    if domain:
        for v in get_vdps():
            for d in v.get("domains", []):
                if domain.endswith(d):
                    return v
    return get_default_vdp() if with_default else None


def get_vdp_by_id(id: str, with_default: bool = False) -> dict:
    if id:
        for v in get_vdps():
            if id == v.get("id", ""):
                return v
    return get_default_vdp() if with_default else None
