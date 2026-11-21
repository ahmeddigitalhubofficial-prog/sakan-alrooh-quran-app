# -*- coding: utf-8 -*-
"""
YouTube Shorts Sync & Replacement Script:
Deletes old scheduled videos (without continuous QR badge) and replaces them with
the newly rendered reels containing the permanent OneLink QR badge and multi-stage CTAs.
"""
import os
import sys
import json
import time
from datetime import datetime, timezone

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from specialists.youtube_publisher import YouTubePublisher
from specialists.campaign_calendar import get_campaign_day
from managing_director import ManagingDirector

OLD_SCHEDULED_MAP = {
    16: {"id": "FLJVDVnNiNo", "date": "2026-11-21"},
    17: {"id": "O4PWkxnkdxg", "date": "2026-11-22"},
    18: {"id": "njJ19B2EdMw", "date": "2026-11-23"},
    19: {"id": "ciCvEAquVME", "date": "2026-11-24"},
    20: {"id": "J7aWPjaxvBA", "date": "2026-11-25"},
    21: {"id": "zh-Bf8Snf1I", "date": "2026-11-26"},
    22: {"id": "klkXRXzUSkg", "date": "2026-11-27"},
    23: {"id": "iYcAvVkX6tY", "date": "2026-11-28"},
    24: {"id": "YAv4JEqQhfc", "date": "2026-11-29"},
}

def sync_remaining_youtube_videos(force_delete_old=True):
    print("=" * 60)
    print(">>> Starting YouTube Replacement & Synchronization...")
    print("=" * 60)

    yp = YouTubePublisher()
    service = yp.get_service()
    if not service:
        print("[!] YouTube Service is not available.")
        return False

    md = ManagingDirector(CURRENT_DIR)
    success_count = 0

    for day_num in range(16, 25):
        info = OLD_SCHEDULED_MAP.get(day_num, {})
        old_id = info.get("id")
        target_date = info.get("date")
        publish_at = f"{target_date}T17:30:00Z"
        
        camp_data = get_campaign_day(day_num)
        pkg = md.prepare_daily_package(day_num)
        new_video_path = pkg["reel_path"]
        title = (pkg["caption"].split("\n")[0] if pkg["caption"] else f"سكن الروح 🌙 يوم {day_num}").strip()
        description = pkg["caption"]

        print(f"\n>>> Checking Day #{day_num} ({target_date})...")

        # 1. Delete old video if present
        if old_id and force_delete_old:
            try:
                print(f"    Deleting old video ID: {old_id}...")
                service.videos().delete(id=old_id).execute()
                print(f"    [OK] Old video {old_id} deleted successfully.")
            except Exception as e:
                print(f"    [Notice] Delete old video {old_id}: {e}")

        # 2. Upload new video with continuous QR badge
        if os.path.exists(new_video_path):
            print(f"    Uploading new reel: {new_video_path}...")
            print(f"    Scheduled publishAt: {publish_at} (8:30 PM Cairo)...")
            yt_res = yp.upload_shorts(new_video_path, title=title, description=description, publish_at=publish_at)
            
            if yt_res.get("success"):
                new_vid = yt_res.get("video_id")
                print(f"    [SUCCESS] Uploaded Day #{day_num} -> https://youtube.com/shorts/{new_vid}")
                OLD_SCHEDULED_MAP[day_num]["id"] = new_vid
                success_count += 1
            else:
                err = str(yt_res.get("error", ""))
                print(f"    [!] Failed to upload Day #{day_num}: {err}")
                if "uploadLimitExceeded" in err:
                    print("\n[ALERT] YouTube daily upload quota limit reached!")
                    print(f"Successfully processed {success_count} videos in this run.")
                    print("Remaining videos will be resumed upon next quota reset.")
                    break
        else:
            print(f"    [ERROR] New video file not found: {new_video_path}")

    print("\n" + "=" * 60)
    print(f">>> Sync Summary: {success_count} new reels uploaded to YouTube.")
    print("=" * 60)
    return True

if __name__ == "__main__":
    sync_remaining_youtube_videos(force_delete_old=False)
