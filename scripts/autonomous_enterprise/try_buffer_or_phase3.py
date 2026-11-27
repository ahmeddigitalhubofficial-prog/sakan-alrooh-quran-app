# -*- coding: utf-8 -*-
"""
1. Tries scheduling Days 1..10 on Buffer using existing Cloudinary URLs (no re-upload).
2. If Buffer is still 429 rate-limited, immediately proceeds to Phase 3 Batch 1:
   renders Days 11..40 and uploads them to Cloudinary (sakan_v2_reels).
"""
import json
import os
import sys
import time
from datetime import datetime, timedelta, timezone

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from managing_director import ManagingDirector
from specialists.buffer_publisher import BufferPublisher
from specialists.campaign_calendar import get_campaign_day
from specialists.reel_director import ReelDirector


def main():
    with open(os.path.join(CURRENT_DIR, "config.json"), "r", encoding="utf-8") as f:
        cfg = json.load(f)
    urls_path = os.path.join(CURRENT_DIR, "cloudinary_v2_urls.json")
    urls = {}
    if os.path.exists(urls_path):
        with open(urls_path, "r", encoding="utf-8") as f:
            urls = json.load(f)

    md = ManagingDirector(CURRENT_DIR)
    md.buffer = BufferPublisher(cfg.get("buffer_api_key", ""), cfg.get("buffer_organization_id", ""))

    # Single clean check (no extra summary call)
    print("=== Checking Buffer API availability ===", flush=True)
    channels = md.buffer.get_connected_channels()
    if channels:
        print(f"Buffer READY! Connected channels: {[c.get('service') for c in channels]}", flush=True)
        base_date = datetime(2026, 11, 27, 18, 30, 0, tzinfo=timezone.utc)
        buffer_ok = 0
        for idx, day_num in enumerate(range(1, 11)):
            due_at = (base_date + timedelta(days=idx)).strftime("%Y-%m-%dT%H:%M:%SZ")
            pkg = md.prepare_daily_package(day_num)
            media_url = urls.get(str(day_num)) or pkg["reel_path"]
            res = md.publish_to_buffer(
                pkg["caption"],
                media_path=media_url,
                due_at=due_at,
                mode="customScheduled",
                skip_youtube=True,
            )
            ok = bool(res.get("success"))
            if ok:
                buffer_ok += 1
            print(f"Buffer Day #{day_num} ({due_at}) -> success={ok}", flush=True)
            time.sleep(2.5)

        with open(os.path.join(CURRENT_DIR, "campaign_state.json"), "w", encoding="utf-8") as f:
            json.dump({"current_day": 11, "last_scheduled_day": 10}, f, indent=2)
        print(f"=== BUFFER PHASE 2 COMPLETE: {buffer_ok}/10 days scheduled ===", flush=True)
        return

    print("Buffer STILL rate-limited (429). Continuing immediately to Phase 3 Batch 1 (Days 11..40)...", flush=True)
    rd = ReelDirector()
    for day_num in range(11, 41):
        camp_data = get_campaign_day(day_num)
        out_path = os.path.join(rd.output_dir, f"reel_day_{day_num}.mp4")
        if not (os.path.exists(out_path) and os.path.getsize(out_path) > 100000):
            print(f"Rendering Day #{day_num} ({camp_data.get('screen_key')})...", flush=True)
            out_path = rd.generate_daily_reel(camp_data, day_num)
        else:
            print(f"Day #{day_num} already rendered.", flush=True)

        if str(day_num) not in urls or not urls[str(day_num)]:
            up_url = md.buffer.upload_media(out_path)
            urls[str(day_num)] = up_url
            with open(urls_path, "w", encoding="utf-8") as f:
                json.dump(urls, f, ensure_ascii=False, indent=2)
            print(f"  -> Cloudinary Day #{day_num}: {up_url}", flush=True)

    print("=== Phase 3 Batch 1 (Days 11..40) Complete ===", flush=True)


if __name__ == "__main__":
    main()
