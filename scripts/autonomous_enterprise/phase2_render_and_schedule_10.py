# -*- coding: utf-8 -*-
"""
Phase 2: Render Days 1..10 of the new 100-video calendar, upload to Cloudinary (sakan_v2_reels),
schedule on Buffer (10 days: 2026-11-27 to 2026-12-06), and schedule on YouTube Shorts.
"""
import json
import os
import sys
import time
from datetime import datetime, timedelta, timezone

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from managing_director import ManagingDirector
from specialists.campaign_calendar import get_campaign_day
from specialists.reel_director import ReelDirector
from specialists.youtube_publisher import YouTubePublisher


def main():
    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()

    base_date = datetime(2026, 11, 27, 18, 30, 0, tzinfo=timezone.utc)  # 8:30 PM Cairo (UTC+2)
    yt_base_date = datetime(2026, 11, 27, 17, 30, 0, tzinfo=timezone.utc)

    print("=== Phase 2 Step 1: Rendering Days 1..10 ===", flush=True)
    for day_num in range(1, 11):
        camp_data = get_campaign_day(day_num)
        print(f"Rendering Day #{day_num} ({camp_data.get('screen_key')})...", flush=True)
        out_path = rd.generate_daily_reel(camp_data, day_num)
        print(f"  -> Ready: {out_path}", flush=True)

    print("\n=== Phase 2 Step 2: Uploading to Cloudinary (sakan_v2_reels) & Scheduling on Buffer ===", flush=True)
    buffer_ok = 0
    for idx, day_num in enumerate(range(1, 11)):
        due_at = (base_date + timedelta(days=idx)).strftime("%Y-%m-%dT%H:%M:%SZ")
        pkg = md.prepare_daily_package(day_num)
        res = md.publish_to_buffer(
            pkg["caption"],
            media_path=pkg["reel_path"],
            due_at=due_at,
            mode="customScheduled",
        )
        ok = bool(res.get("success"))
        if ok:
            buffer_ok += 1
        print(f"Buffer Day #{day_num} ({due_at}) -> success={ok}, posts={len(res.get('posts', []))}", flush=True)
        time.sleep(1.5)

    with open(os.path.join(CURRENT_DIR, "campaign_state.json"), "w", encoding="utf-8") as f:
        json.dump({"current_day": 11, "last_scheduled_day": 10}, f, indent=2)
    print(f"Updated campaign_state.json -> last_scheduled_day=10 (Buffer scheduled: {buffer_ok}/10 days)", flush=True)

    print("\n=== Phase 2 Step 3: Cleaning old YouTube private videos & Scheduling Days 1..10 ===", flush=True)
    yp = YouTubePublisher(CURRENT_DIR)
    service = yp.get_service()
    if not service:
        print("YouTube service unavailable!", flush=True)
        return

    # Fetch existing private scheduled videos before uploading new ones
    ch = service.channels().list(part="contentDetails", mine=True).execute()
    pl = ch["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"]
    items = service.playlistItems().list(part="contentDetails", playlistId=pl, maxResults=30).execute()
    vids = [i["contentDetails"]["videoId"] for i in items["items"]]
    old_private_ids = []
    if vids:
        det = service.videos().list(part="status", id=",".join(vids)).execute()["items"]
        old_private_ids = [v["id"] for v in det if v["status"].get("privacyStatus") == "private"]
    print(f"Found {len(old_private_ids)} existing private scheduled videos on YouTube.", flush=True)

    yt_ok = 0
    for idx, day_num in enumerate(range(1, 11)):
        publish_at = (yt_base_date + timedelta(days=idx)).strftime("%Y-%m-%dT%H:%M:%SZ")
        pkg = md.prepare_daily_package(day_num)
        title = (pkg["caption"].split("\n")[0] if pkg["caption"] else f"Sakan Al-Rooh Day {day_num}").strip()
        print(f"Uploading YouTube Day #{day_num} ({publish_at})...", flush=True)
        yt_res = yp.upload_shorts(pkg["reel_path"], title=title, description=pkg["caption"], publish_at=publish_at)
        if yt_res.get("success"):
            yt_ok += 1
            print(f"  -> Uploaded Day #{day_num}: {yt_res.get('video_id')}", flush=True)
        else:
            print(f"  -> YouTube stopped at Day #{day_num}: {yt_res.get('error')}", flush=True)
            break

    if yt_ok > 0 and old_private_ids:
        print(f"Deleting {len(old_private_ids)} old private scheduled YouTube videos...", flush=True)
        for oid in old_private_ids:
            try:
                service.videos().delete(id=oid).execute()
                print(f"  -> Deleted old video {oid}", flush=True)
            except Exception as e:
                print(f"  -> Could not delete {oid}: {e}", flush=True)

    print(f"\n=== Phase 2 Complete: Buffer={buffer_ok}/10, YouTube={yt_ok}/10 ===", flush=True)


if __name__ == "__main__":
    main()
