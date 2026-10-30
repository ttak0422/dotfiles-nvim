#!/usr/bin/env python3
"""Small stdio LSP boundary fixture; never reads project files."""
import json
import sys

while True:
    headers = {}
    while line := sys.stdin.buffer.readline():
        if line in (b"\r\n", b"\n"):
            break
        key, value = line.decode().split(":", 1)
        headers[key.lower()] = value.strip()
    if not headers:
        break
    request = json.loads(sys.stdin.buffer.read(int(headers["content-length"])))
    if request.get("method") == "exit":
        break
    if "id" not in request:
        continue
    result = {"capabilities": {"textDocumentSync": 1}} if request["method"] == "initialize" else None
    body = json.dumps({"jsonrpc": "2.0", "id": request["id"], "result": result}).encode()
    sys.stdout.buffer.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
    sys.stdout.buffer.flush()
