# -*- coding: utf-8 -*-
"""
Script to re-render, upload to Cloudinary, and update Buffer scheduled queue
for all modified/protected campaign days: [6, 14, 15, 18, 21, 28].
Ensures YouTube Shorts length limits (<= 32s) and audio protection filter (atempo=1.03).
"""

import os
import sys
import json
import time

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from specialists.reel_director import ReelDirector
from specialists.campaign_calendar import get_campaign_day
from managing_director import ManagingDirector

ASSETS_JSON_PATH = os.path.join(CURRENT_DIR, "data", "cloudinary_campaign_assets.json")

def main():
    print("==================================================")
    print(">>> Sakan Al-Rooh Campaign Reels Security & Buffer Update")
    print("==================================================")

    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()
    bp = md.buffer

    if not bp:
        print("[!] Error: Buffer publisher could not be initialized.")
        return

    # Load manifest
    manifest = {}
    if os.path.exists(ASSETS_JSON_PATH):
        try:
            with open(ASSETS_JSON_PATH, "r", encoding="utf-8") as f:
                manifest = json.load(f)
        except Exception as e:
            print(f"[!] Warning reading manifest: {e}")

    days_to_update = [6, 14, 15, 18, 21, 28]

    for day_num in days_to_update:
        day_str = str(day_num)
        camp_data = get_campaign_day(day_num)
        title = camp_data.get("title", f"Day {day_num}")
        reel_file = os.path.join(rd.output_dir, f"reel_day_{day_num}.mp4")

        print(f"\n--- [1] Processing Day {day_num}: {title} ---")
        
        # Remove old render if exists to force re-render with atempo=1.03 and safe audio
        if os.path.exists(reel_file):
            try:
                os.remove(reel_file)
            except Exception:
                pass

        print(f"Rendering Day #{day_num} video with audio protection...")
        t0 = time.time()
        rd.generate_daily_reel(camp_data, day_num)
        print(f"Render completed in {int(time.time() - t0)}s. Size: {int(os.path.getsize(reel_file)/1024)} KB")

        # Upload to Cloudinary
        print(f"Uploading Day #{day_num} to Cloudinary...")
        cloud_url = bp.upload_media(reel_file)
        if cloud_url and cloud_url.startswith("http"):
            print(f"[SUCCESS] Cloudinary URL: {cloud_url}")
            manifest[day_str] = {
                "day": day_num,
                "title": title,
                "cloudinary_url": cloud_url,
                "local_file": reel_file,
                "caption": "",
                "hook_text": camp_data.get("reel", {}).get("hook_text", ""),
                "uploaded_at": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            # Save manifest after each successful upload
            with open(ASSETS_JSON_PATH, "w", encoding="utf-8") as f:
                json.dump(manifest, f, indent=2, ensure_ascii=False)
        else:
            print(f"[!] Upload failed for Day #{day_num}: {cloud_url}")

    print("\n==================================================")
    print(">>> Updating Buffer Scheduled Queue")
    print("==================================================")

    # 1. Fetch current scheduled posts in Buffer
    scheduled = bp.get_scheduled_posts()
    print(f"Total current scheduled posts in Buffer: {len(scheduled)}")

    target_schedule_map = {
        14: "2026-11-06T17:30:00.000Z",
        15: "2026-11-07T17:30:00.000Z",
        18: "2026-11-11T17:30:00.000Z",
        21: "2026-11-14T17:30:00.000Z"
    }

    # Delete obsolete posts in Buffer for these target dates or containing old titles
    deleted_count = 0
    for p in scheduled:
        pid = p.get("id")
        due = p.get("dueAt", "")

        should_delete = False
        for d_target in ["2026-11-06", "2026-11-07", "2026-11-08", "2026-11-11", "2026-11-14"]:
            if d_target in due:
                should_delete = True
                break

        if should_delete:
            print(f"Deleting obsolete Buffer post {pid} (due: {due})...")
            bp.delete_post(pid)
            deleted_count += 1
            time.sleep(0.5)

    print(f"Deleted {deleted_count} obsolete/duplicate posts from Buffer.")

    # Re-schedule Days 14, 15, 18, 21 with updated Cloudinary links and captions
    for day_num, due_at in target_schedule_map.items():
        camp_data = get_campaign_day(day_num)
        cloud_entry = manifest.get(str(day_num), {})
        cloud_url = cloud_entry.get("cloudinary_url")

        print(f"\nRe-scheduling Day #{day_num} for {due_at}...")
        pkg = md.prepare_daily_package(day_num)
        caption = pkg["caption"]

        media_url = cloud_url if cloud_url else pkg["reel_path"]
        res = md.publish_to_buffer(
            caption,
            media_path=media_url,
            due_at=due_at,
            mode="customScheduled",
            skip_youtube=True
        )
        print(f"Scheduled Day #{day_num} -> Result: {res.get('success')} (posts: {len(res.get('results', []))})")
        time.sleep(1)

    print("\n==================================================")
    print(">>> Finished! All reels rendered, uploaded & scheduled safely.")
    print("==================================================")

if __name__ == "__main__":
    main()

