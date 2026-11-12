# -*- coding: utf-8 -*-
"""
Full Month Cloudinary Asset Factory (Pre-render & Upload All 30 Days)
ينتج جميع فيديوهات الريلز للشهر كامل (30 يوماً) ويرفعها إلى Cloudinary
ويحفظ الروابط في data/cloudinary_campaign_assets.json
لتصبح المنظومة سحابية 100% ومستقلة تماماً عن جهاز الكمبيوتر وقت النشر والتعويض.
"""

import os
import sys
import json
import time

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from specialists.reel_director import ReelDirector
from specialists.campaign_calendar import get_campaign_day, CAMPAIGN_DAYS
from specialists.buffer_publisher import BufferPublisher
from managing_director import ManagingDirector

ASSETS_JSON_PATH = os.path.join(CURRENT_DIR, "data", "cloudinary_campaign_assets.json")
os.makedirs(os.path.dirname(ASSETS_JSON_PATH), exist_ok=True)

def load_assets_manifest():
    if os.path.exists(ASSETS_JSON_PATH):
        try:
            with open(ASSETS_JSON_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def save_assets_manifest(manifest):
    with open(ASSETS_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Full Month Cloudinary Asset Factory")
    parser.add_argument("--month", type=int, default=0, help="Month number (1 or 2, default: 0 for all)")
    parser.add_argument("--start", type=int, default=0, help="Start day")
    parser.add_argument("--end", type=int, default=0, help="End day")
    args = parser.parse_args()

    print("=" * 60)
    print(">>> Sakan Al-Rooh - Full Month Cloudinary Asset Factory")
    print("=" * 60)

    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()
    bp = md.buffer

    if not bp:
        print("[!] Error: Buffer/Cloudinary publisher not initialized.")
        return

    manifest = load_assets_manifest()
    
    if args.month == 1:
        target_days = list(range(1, 31))
    elif args.month == 2:
        target_days = list(range(31, 61))
    elif args.start > 0 and args.end >= args.start:
        target_days = list(range(args.start, args.end + 1))
    else:
        target_days = list(range(1, len(CAMPAIGN_DAYS) + 1))

    print(f">>> Target Days: {target_days[0]} to {target_days[-1]} ({len(target_days)} days)")

    for day_num in target_days:
        day_str = str(day_num)
        camp_data = get_campaign_day(day_num)
        title = camp_data.get("title", f"Day {day_num}")

        # Check if already in manifest with valid URL
        existing = manifest.get(day_str, {})
        if existing.get("cloudinary_url") and existing["cloudinary_url"].startswith("http"):
            print(f"[✓] Day #{day_num} already uploaded: {existing['cloudinary_url'][:55]}...")
            continue

        print(f"\n------------------------------------------------------------")
        print(f">>> Processing Day #{day_num}: {title}")
        print(f"------------------------------------------------------------")

        reel_file = os.path.join(rd.output_dir, f"reel_day_{day_num}.mp4")

        # 1. Render if needed
        if not os.path.exists(reel_file) or os.path.getsize(reel_file) < 10000:
            print(f">>> Rendering Video Reel Day #{day_num}...")
            t0 = time.time()
            rd.generate_daily_reel(camp_data, day_num)
            print(f">>> Render complete in {int(time.time() - t0)}s!")
        else:
            print(f">>> Local reel found ({int(os.path.getsize(reel_file)/1024)} KB).")

        # 2. Upload to Cloudinary
        print(f">>> Uploading Day #{day_num} to Cloudinary...")
        cloud_url = bp.upload_media(reel_file)

        if cloud_url and cloud_url.startswith("http"):
            print(f"[SUCCESS] Cloudinary URL: {cloud_url}")
            manifest[day_str] = {
                "day": day_num,
                "title": title,
                "cloudinary_url": cloud_url,
                "local_file": reel_file,
                "caption": camp_data.get("caption", ""),
                "hook_text": camp_data.get("reel", {}).get("hook_text", ""),
                "uploaded_at": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            save_assets_manifest(manifest)
        else:
            print(f"[!] Upload failed for Day #{day_num}!")

        # Brief sleep between iterations
        time.sleep(1)

    print("\n" + "=" * 60)
    print(">>> All 30 Days Processed and Saved to Manifest!")
    print(f">>> Manifest Path: {ASSETS_JSON_PATH}")
    print("=" * 60)

if __name__ == "__main__":
    main()

