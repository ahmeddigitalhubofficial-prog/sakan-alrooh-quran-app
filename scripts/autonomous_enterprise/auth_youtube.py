# -*- coding: utf-8 -*-
"""
One-Time YouTube Authentication Helper for Sakan Al-Rooh
Opens browser to authorize YouTube upload access and stores credentials in youtube_token.json.
"""

import os
import sys
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = [
    "https://www.googleapis.com/auth/youtube.upload",
    "https://www.googleapis.com/auth/youtube.readonly"
]

def main():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    client_secret = os.path.join(current_dir, "client_secret.json")
    token_file = os.path.join(current_dir, "youtube_token.json")

    if not os.path.exists(client_secret):
        print(f"[!] Error: client_secret.json not found in: {current_dir}")
        return

    print(">>> Starting YouTube OAuth authentication...")
    print("Browser will now open to sign in and authorize Sakan Al-Rooh channel.\n")

    flow = InstalledAppFlow.from_client_secrets_file(
        client_secret,
        scopes=SCOPES
    )

    try:
        creds = flow.run_local_server(
            host="localhost",
            port=8080,
            authorization_prompt_message="Please visit the following URL if browser does not open automatically:\n{url}\n",
            success_message="Authentication successful! You may now close this browser window and return to terminal.",
            open_browser=True
        )

        with open(token_file, "w", encoding="utf-8") as f:
            f.write(creds.to_json())

        print("\n" + "="*50)
        print("[SUCCESS] YouTube credentials saved successfully to:")
        print(token_file)
        print("YouTube Shorts publisher is now authenticated and ready.")
        print("="*50 + "\n")

    except Exception as e:
        print(f"\n[!] Authentication error: {e}")

if __name__ == "__main__":
    main()
