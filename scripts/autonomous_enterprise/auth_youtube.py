# -*- coding: utf-8 -*-
"""
One-Time YouTube Authentication Helper for Sakan Al-Rooh
Opens browser to authorize YouTube access and exchanges the OAuth code via curl.exe
to avoid Python 3.14 TLS SSLEOFError on oauth2.googleapis.com.
"""

import json
import os
import subprocess
import urllib.parse
import webbrowser
from datetime import datetime, timedelta, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

SCOPES = [
    "https://www.googleapis.com/auth/youtube.upload",
    "https://www.googleapis.com/auth/youtube.readonly",
    "https://www.googleapis.com/auth/youtube.force-ssl",
]


def main():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    client_secret_path = os.path.join(current_dir, "client_secret.json")
    token_file = os.path.join(current_dir, "youtube_token.json")

    if not os.path.exists(client_secret_path):
        print(f"[!] Error: client_secret.json not found in: {current_dir}")
        return

    with open(client_secret_path, "r", encoding="utf-8") as f:
        secret_data = json.load(f)
    client_cfg = secret_data.get("installed") or secret_data.get("web") or {}
    client_id = client_cfg.get("client_id", "")
    client_secret = client_cfg.get("client_secret", "")
    redirect_uri = "http://localhost:8080/"

    auth_params = urllib.parse.urlencode({
        "client_id": client_id,
        "redirect_uri": redirect_uri,
        "response_type": "code",
        "scope": " ".join(SCOPES),
        "access_type": "offline",
        "prompt": "consent",
    })
    auth_url = f"https://accounts.google.com/o/oauth2/auth?{auth_params}"

    captured = {"code": None, "error": None}

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            parsed = urllib.parse.urlparse(self.path)
            qs = urllib.parse.parse_qs(parsed.query)
            if "code" in qs:
                captured["code"] = qs["code"][0]
                msg = b"Authentication successful! You may now close this browser window and return to terminal."
            else:
                captured["error"] = qs.get("error", ["unknown"])[0]
                msg = b"Authentication failed. Check terminal."
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(msg)

        def log_message(self, format, *args):
            return

    print(">>> Starting YouTube OAuth authentication...")
    print("Browser will now open to sign in and authorize Sakan Al-Rooh channel.\n")
    server = HTTPServer(("localhost", 8080), Handler)
    webbrowser.open(auth_url)

    while captured["code"] is None and captured["error"] is None:
        server.handle_request()
    server.server_close()

    if captured["error"] or not captured["code"]:
        print(f"[!] Authentication error: {captured['error']}")
        return

    print(">>> Exchanging authorization code via curl.exe...")
    cmd = [
        "curl.exe", "-s", "-X", "POST", "https://oauth2.googleapis.com/token",
        "-d", f"code={captured['code']}",
        "-d", f"client_id={client_id}",
        "-d", f"client_secret={client_secret}",
        "-d", f"redirect_uri={redirect_uri}",
        "-d", "grant_type=authorization_code",
    ]
    res = subprocess.check_output(cmd, timeout=20).decode("utf-8")
    tok = json.loads(res)
    if "access_token" not in tok:
        print(f"[!] Token exchange failed: {tok}")
        return

    exp = datetime.now(timezone.utc) + timedelta(seconds=tok.get("expires_in", 3600))
    creds_json = {
        "token": tok["access_token"],
        "refresh_token": tok.get("refresh_token", ""),
        "token_uri": "https://oauth2.googleapis.com/token",
        "client_id": client_id,
        "client_secret": client_secret,
        "scopes": SCOPES,
        "expiry": exp.strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
    }
    with open(token_file, "w", encoding="utf-8") as f:
        json.dump(creds_json, f, indent=2)

    print("\n" + "=" * 50)
    print("[SUCCESS] YouTube credentials saved successfully to:")
    print(token_file)
    print("YouTube Shorts publisher is now authenticated with full delete scope.")
    print("=" * 50 + "\n")


if __name__ == "__main__":
    main()
