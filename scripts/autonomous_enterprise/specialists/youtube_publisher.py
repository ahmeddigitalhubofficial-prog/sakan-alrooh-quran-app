# -*- coding: utf-8 -*-
"""
YouTube Shorts Direct Publisher
Uploads vertical video Reels directly to Sakan Al-Rooh YouTube channel via YouTube Data API v3
independently of Buffer without channel limits.
"""

import os
import json
import time
try:
    from google.oauth2.credentials import Credentials
    from google_auth_oauthlib.flow import InstalledAppFlow
    from google.auth.transport.requests import Request
    from googleapiclient.discovery import build
    from googleapiclient.http import MediaFileUpload
    GOOGLE_AVAILABLE = True
except ImportError:
    GOOGLE_AVAILABLE = False

SCOPES = [
    "https://www.googleapis.com/auth/youtube.upload",
    "https://www.googleapis.com/auth/youtube.readonly"
]

class YouTubePublisher:
    def __init__(self, base_dir=None):
        self.base_dir = base_dir or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.token_file = os.path.join(self.base_dir, "youtube_token.json")
        self.client_secret_file = os.path.join(self.base_dir, "client_secret.json")
        self.youtube = None

    def is_authenticated(self):
        """Check if a valid YouTube OAuth token exists"""
        if not GOOGLE_AVAILABLE:
            return False
        if not os.path.exists(self.token_file):
            return False
        try:
            creds = Credentials.from_authorized_user_file(self.token_file, SCOPES)
            if creds and creds.valid:
                return True
            if creds and creds.expired and creds.refresh_token:
                for attempt in range(3):
                    try:
                        creds.refresh(Request())
                        with open(self.token_file, "w", encoding="utf-8") as token:
                            token.write(creds.to_json())
                        return True
                    except Exception as err:
                        if attempt == 2:
                            print(f"YouTube Auth Check Error: {err}")
                        time.sleep(1)
        except Exception as e:
            print(f"YouTube Auth Check Error: {e}")
        return False

    def get_service(self):
        """Retrieve authorized YouTube API service resource"""
        if self.youtube:
            return self.youtube

        creds = None
        if os.path.exists(self.token_file):
            try:
                creds = Credentials.from_authorized_user_file(self.token_file, SCOPES)
            except Exception as e:
                print(f"Error loading token: {e}")

        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                for attempt in range(3):
                    try:
                        creds.refresh(Request())
                        with open(self.token_file, "w", encoding="utf-8") as token:
                            token.write(creds.to_json())
                        break
                    except Exception as e:
                        if attempt == 2:
                            print(f"Error refreshing token: {e}")
                            creds = None
                        time.sleep(1)

            if not creds:
                if not os.path.exists(self.client_secret_file):
                    candidates = [f for f in os.listdir(self.base_dir) if f.startswith("client_secret") and f.endswith(".json")]
                    if candidates:
                        self.client_secret_file = os.path.join(self.base_dir, candidates[0])
                    else:
                        return None

                flow = InstalledAppFlow.from_client_secrets_file(
                    self.client_secret_file,
                    scopes=SCOPES
                )
                creds = flow.run_local_server(
                    host="localhost",
                    port=8080,
                    authorization_prompt_message=">>> Open the following URL to authenticate:\n{url}\n",
                    success_message="Authentication successful! You can close this window.",
                    open_browser=True
                )
                with open(self.token_file, "w", encoding="utf-8") as token:
                    token.write(creds.to_json())

        self.youtube = build("youtube", "v3", credentials=creds)
        return self.youtube

    def upload_shorts(self, video_path, title=None, description=None, tags=None, privacy="public", publish_at=None):
        """
        Uploads a video to YouTube Shorts with optional scheduled publication
        - video_path: local path to .mp4
        - title: shorts title (max 100 chars, includes #Shorts)
        - description: full description with links
        - privacy: 'public', 'unlisted', or 'private'
        - publish_at: ISO 8601 UTC string (e.g. 2026-11-05T17:30:00Z) for future scheduled release
        """
        temp_file_to_clean = None
        if video_path and video_path.startswith("http"):
            try:
                import urllib.request
                import tempfile
                print(f"Downloading video from Cloudinary: {video_path[:50]}...")
                temp_video = tempfile.NamedTemporaryFile(delete=False, suffix=".mp4")
                urllib.request.urlretrieve(video_path, temp_video.name)
                temp_video.close()
                video_path = temp_video.name
                temp_file_to_clean = temp_video.name
            except Exception as e:
                return {
                    "success": False,
                    "error": f"Failed to download video from URL: {e}"
                }

        if not video_path or not os.path.exists(video_path):
            return {
                "success": False,
                "error": f"Video file not found: {video_path}"
            }

        service = self.get_service()
        if not service:
            return {
                "success": False,
                "error": "YouTube not authenticated. Missing client_secret.json or youtube_token.json."
            }

        clean_title = (title or "سكن الروح 🌙").strip()
        if len(clean_title) > 85:
            clean_title = clean_title[:85].strip()
        if not any(tag in clean_title.lower() for tag in ["#shorts", "#short"]):
            clean_title += " #Shorts"

        default_desc = (
            f"{clean_title}\n\n"
            "📲 حمل تطبيق «سكن الروح» مجاناً وبدون أي إعلانات لوجه الله:\n"
            "🔗 الرابط الشامل لجميع الأجهزة: https://linktr.ee/sakan.alrooh.app\n"
            "🟢 متجر Google Play: https://play.google.com/store/apps/details?id=com.nooralhoda.official.app\n"
            "🔴 متجر Huawei AppGallery: https://appgallery.huawei.com/app/C118816285\n\n"
            "📺 القناة الرسمية على يوتيوب: https://www.youtube.com/@SakanAl-Rooh\n\n"
            "#سكن_الروح #قرآن_كريم #أذكار #دعاء #تلاوة_خاشعة #Shorts #Quran"
        )
        final_desc = description or default_desc
        final_tags = tags or ["سكن الروح", "قرآن", "أذكار", "تلاوات", "Shorts", "Quran", "Islam"]

        status_dict = {
            "selfDeclaredMadeForKids": False
        }

        # If a future schedule is requested, privacy must be private and publishAt set
        if publish_at:
            status_dict["privacyStatus"] = "private"
            status_dict["publishAt"] = publish_at
        else:
            status_dict["privacyStatus"] = privacy

        body = {
            "snippet": {
                "title": clean_title,
                "description": final_desc,
                "tags": final_tags,
                "categoryId": "22"
            },
            "status": status_dict
        }

        media = MediaFileUpload(
            video_path,
            chunksize=-1,
            resumable=True,
            mimetype="video/mp4"
        )

        try:
            print(f">>> Uploading to YouTube Shorts: {clean_title}...")
            request = service.videos().insert(
                part="snippet,status",
                body=body,
                media_body=media
            )
            response = None
            while response is None:
                status, response = request.next_chunk()
                if status:
                    print(f"Uploading to YouTube: {int(status.progress() * 100)}%")

            video_id = response.get("id")
            shorts_url = f"https://youtube.com/shorts/{video_id}"
            watch_url = f"https://www.youtube.com/watch?v={video_id}"

            print(f"[SUCCESS] Uploaded to YouTube Shorts: {shorts_url}")
            return {
                "success": True,
                "video_id": video_id,
                "shorts_url": shorts_url,
                "watch_url": watch_url,
                "title": clean_title
            }
        except Exception as e:
            print(f"[!] Error uploading to YouTube: {e}")
            return {
                "success": False,
                "error": str(e)
            }
        finally:
            if temp_file_to_clean and os.path.exists(temp_file_to_clean):
                try:
                    os.remove(temp_file_to_clean)
                except Exception:
                    pass

    def get_channel_info(self):
        """Fetch authenticated channel info without uploading"""
        try:
            service = self.get_service()
            if not service:
                return None
            res = service.channels().list(part="snippet,statistics", mine=True).execute()
            items = res.get("items", [])
            if items:
                channel = items[0]
                return {
                    "title": channel["snippet"]["title"],
                    "custom_url": channel["snippet"].get("customUrl", ""),
                    "subscribers": channel["statistics"].get("subscriberCount", "0"),
                    "videos": channel["statistics"].get("videoCount", "0")
                }
        except Exception as e:
            print(f"Error fetching channel info: {e}")
        return None

if __name__ == "__main__":
    import sys
    yp = YouTubePublisher()
    if "--auth" in sys.argv:
        print("Starting YouTube OAuth flow...")
        svc = yp.get_service()
        if svc:
            print("[SUCCESS] YouTube authentication successful. Saved youtube_token.json!")
        else:
            print("[!] Authentication failed. Ensure client_secret.json is present.")
    elif "--test-connection" in sys.argv:
        info = yp.get_channel_info()
        if info:
            print("="*50)
            print("[SUCCESS] YouTube Channel Connection Verified (Read-Only):")
            print(f"Channel Name:        {info['title']}")
            print(f"Channel Handle/URL:  {info['custom_url']}")
            print(f"Subscribers:         {info['subscribers']}")
            print(f"Total Videos:        {info['videos']}")
            print("="*50)
        else:
            print("[!] Could not fetch channel info. Please run auth_youtube.bat first.")
    else:
        status = "AUTHENTICATED & READY" if yp.is_authenticated() else "NOT AUTHENTICATED (Missing token)"
        print(f"YouTube Connection Status: {status}")

