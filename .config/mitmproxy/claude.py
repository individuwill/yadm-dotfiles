#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "mitmproxy",
# ]
# ///

import json
import hashlib
from uuid import uuid4
from mitmproxy import http


def hash_settings(settings: dict) -> str:
    settings_json = json.dumps(settings, separators=(",", ":"))
    settings_hash = hashlib.sha256(settings_json.encode()).hexdigest()
    return settings_hash


def build_settings_payload(settings: dict, uuid: str | None = None) -> dict:
    settings_hash = hash_settings(settings)
    payload = {
        "uuid": uuid or str(uuid4()),
        "checksum": f"sha256:{settings_hash}",
        "settings": settings,
    }
    return payload


def test_hash_settings():
    settings = {
        "disableAutoMode": "disable",
        "permissions": {"disableBypassPermissionsMode": "disable"},
        "skipDangerousModePermissionPrompt": False,
    }
    expected_hash = "da1477f66af4d15afb4d5a1ae3c89ed9b95f30a7505b5c523fe9b84e2c4ac347"
    settings_hash = hash_settings(settings)
    print(f"Settings JSON: {json.dumps(settings, separators=(',', ':'))}")
    print(f"Settings Hash: {settings_hash}")
    assert settings_hash == expected_hash


def test_build_settings_payload():
    settings = {
        "disableAutoMode": "disable",
        "permissions": {"disableBypassPermissionsMode": "disable"},
        "skipDangerousModePermissionPrompt": False,
    }
    payload = build_settings_payload(settings)
    print(f"Settings Payload: {json.dumps(payload, indent=2)}")
    assert (
        payload["checksum"]
        == "sha256:da1477f66af4d15afb4d5a1ae3c89ed9b95f30a7505b5c523fe9b84e2c4ac347"
    )


def build_my_settings_payload(uuid: str | None = None) -> dict:
    my_settings = {
        # "disableAutoMode": "disable",
        "permissions": {"disableBypassPermissionsMode": "disable"},
        "skipDangerousModePermissionPrompt": False,
    }
    return build_settings_payload(my_settings, uuid)


class ClaudeSettingsModifier:
    def __init__(self):
        print("ClaudeSettingsModifier initialized")

    def request(self, flow: http.HTTPFlow) -> None:
        req = flow.request

        if req.host == "api.anthropic.com":
            print("Intercepted request to api.anthropic.com")

            if req.path == "/api/claude_code/settings":
                print("Intercepted request to /api/claude_code/settings")
                print(f"Method: {req.method}")
                print(f"Path: {req.path}")
                print(f"Headers: {req.headers}")
                payload = build_my_settings_payload()
                flow.response = http.Response.make(
                    200,
                    json.dumps(payload),
                    {"Content-Type": "application/json"},
                )
                print(
                    f"Responding with custom settings payload: {json.dumps(payload, indent=2)}"
                )

    def response(self, flow: http.HTTPFlow) -> None:
        pass


# /api/claude_code/policy_limits
# {
#     "restrictions": {
#         "allow_remote_control": {
#             "allowed": false
#         },
#         "allow_quick_web_setup": {
#             "allowed": false
#         },
#         "enforce_web_search_mcp_isolation": {
#             "allowed": false
#         }
#     },
#     "compliance_taints": []
# }

# header "If-None-Match" = "sha256:da1477f66af4d15afb4d5a1ae3c89ed9b95f30a7505b5c523fe9b84e2c4ac347"
# /api/claude_code/settings
# {
#     "uuid": "7ba54b47-2992-4bb2-9c26-70d03e405652",
#     "checksum": "sha256:da1477f66af4d15afb4d5a1ae3c89ed9b95f30a7505b5c523fe9b84e2c4ac347",
#     "settings": {
#         "disableAutoMode": "disable",
#         "permissions": {
#             "disableBypassPermissionsMode": "disable"
#         },
#         "skipDangerousModePermissionPrompt": false
#     }
# }


addons = [ClaudeSettingsModifier()]


def main():
    print("mitmproxy claude.py")
    test_hash_settings()
    test_build_settings_payload()


if __name__ == "__main__":
    main()
