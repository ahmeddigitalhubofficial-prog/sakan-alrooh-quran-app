# -*- coding: utf-8 -*-
"""
Re-renders the 10 currently scheduled campaign days with the new 3-store Search CTA
and feature-linked ReelDirector, then updates Buffer and YouTube safely.
"""
import os
import sys

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from managing_director import ManagingDirector
from specialists.reel_director import ReelDirector
from specialists.campaign_calendar import get_campaign_day
from specialists.youtube_publisher import YouTubePublisher

BUFFER_PLAN = [
    (22, "2026-11-27T18:30:00Z"),
    (23, "2026-11-28T18:30:00Z"),
    (24, "2026-11-29T18:30:00Z"),
    (40, "2026-11-30T18:30:00Z"),
    (18, "2026-12-01T18:30:00Z"),
    (19, "2026-12-02T18:30:00Z"),
    (41, "2026-12-03T18:30:00Z"),
    (42, "2026-12-04T18:30:00Z"),
    (43, "2026-12-05T18:30:00Z"),
    (44, "2026-12-06T18:30:00Z"),
]

YOUTUBE_PLAN = [
    (22, "2026-11-27T17:30:00Z", "MuOTfyYnPpw"),
    (23, "2026-11-28T17:30:00Z", "Qd9prOxzHWM"),
    (24, "2026-11-29T17:30:00Z", "W9W78SkPKCw"),
    (41, "2026-12-03T17:30:00Z", "djQXy_LqbzA"),
    (42, "2026-12-04T17:30:00Z", "-0bqutARwMo"),
    (43, "2026-12-05T17:30:00Z", "LvWGTBLGMPg"),
    (44, "2026-12-06T17:30:00Z", "-B4NDS7nzos"),
]


def main():
    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()

    # 1. Re-render all 10 scheduled days with the new ReelDirector
    print("=== Step 1: Re-rendering 10 scheduled reels ===", flush=True)
    for day_num, _ in BUFFER_PLAN:
        camp_data = get_campaign_day(day_num)
        print(f"Rendering Day #{day_num} ({camp_data.get('screen_key')})...", flush=True)
        out_path = rd.generate_daily_reel(camp_data, day_num)
        print(f"  -> Ready: {out_path}", flush=True)

    # 2. Clear and reschedule Buffer
    print("\n=== Step 2: Updating Buffer queue ===", flush=True)
    del_res = md.clear_buffer_schedule()
    print("Buffer clear result:", del_res, flush=True)

    for day_num, due_at in BUFFER_PLAN:
        pkg = md.prepare_daily_package(day_num)
        res = md.publish_to_buffer(
            pkg["caption"],
            media_path=pkg["reel_path"],
            due_at=due_at,
            mode="customScheduled",
        )
        print(f"Buffer Day #{day_num} ({due_at}) -> success={res.get('success')} posts={len(res.get('posts', []))}", flush=True)

    # 3. Safe YouTube replacement (upload new first, delete old only on success)
    print("\n=== Step 3: Updating YouTube scheduled videos ===", flush=True)
    yp = YouTubePublisher()
    service = yp.get_service()
    if not service:
        print("YouTube service unavailable!", flush=True)
        return

    for day_num, publish_at, old_id in YOUTUBE_PLAN:
        pkg = md.prepare_daily_package(day_num)
        video_path = pkg["reel_path"]
        title = (pkg["caption"].split("\n")[0] if pkg["caption"] else f"Sakan Al-Rooh Day {day_num}").strip()
        description = pkg["caption"]

        print(f"Uploading YouTube Day #{day_num} ({publish_at})...", flush=True)
        yt_res = yp.upload_shorts(video_path, title=title, description=description, publish_at=publish_at)
        if yt_res.get("success"):
            new_id = yt_res.get("video_id")
            print(f"  -> Uploaded new ID: {new_id}", flush=True)
            try:
                service.videos().delete(id=old_id).execute()
                print(f"  -> Deleted old ID: {old_id}", flush=True)
            except Exception as e:
                print(f"  -> Warning deleting old ID {old_id}: {e}", flush=True)
        else:
            print(f"  -> Upload failed/quota reached for Day #{day_num}: {yt_res}", flush=True)
            print("  -> Keeping old scheduled video intact and stopping YouTube loop.", flush=True)
            break

    print("\n=== Done ===", flush=True)


if __name__ == "__main__":
    main()
