import json
import subprocess
from datetime import datetime, timezone, timedelta
import os

TOKEN_FILE = os.path.join(os.path.dirname(__file__), "youtube_token.json")

def refresh():
    with open(TOKEN_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    cmd = [
        "curl.exe", "-s", "-X", "POST", "https://oauth2.googleapis.com/token",
        "-d", f"client_id={data['client_id']}",
        "-d", f"client_secret={data['client_secret']}",
        "-d", f"refresh_token={data['refresh_token']}",
        "-d", "grant_type=refresh_token"
    ]
    res = subprocess.check_output(cmd).decode("utf-8")
    new_data = json.loads(res)
    if "access_token" in new_data:
        data["token"] = new_data["access_token"]
        data["expiry"] = (datetime.now(timezone.utc) + timedelta(seconds=new_data["expires_in"])).strftime("%Y-%m-%dT%H:%M:%S.%fZ")
        with open(TOKEN_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
        print("SUCCESS: Token refreshed and saved!")
        return True
    else:
        print("ERROR:", res)
        return False

if __name__ == "__main__":
    refresh()
