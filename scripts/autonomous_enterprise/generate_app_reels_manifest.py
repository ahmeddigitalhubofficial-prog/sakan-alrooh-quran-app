# -*- coding: utf-8 -*-
"""
Generates the in-app spiritual reels manifest: assets/data/spiritual_reels.json
Combines campaign calendar metadata with Cloudinary URLs and YouTube Shorts URLs.
"""
import os
import json
from datetime import datetime, timedelta

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(base_dir, "..", ".."))
    
    # 1. Load Cloudinary Assets
    cloudinary_path = os.path.join(base_dir, "data", "cloudinary_campaign_assets.json")
    with open(cloudinary_path, "r", encoding="utf-8") as f:
        cloud_data = json.load(f)
        
    # 2. Import Campaign Days
    import sys
    sys.path.append(base_dir)
    from specialists.campaign_calendar import CAMPAIGN_DAYS
    
    # YouTube Shorts map for scheduled/published shorts
    youtube_shorts_map = {
        9: "https://youtube.com/shorts/2j5efzc5k0c",
        10: "https://youtube.com/shorts/Qsj9FdgQoVI",
        11: "https://youtube.com/shorts/pLCAMGf2QIA",
        12: "https://youtube.com/shorts/-N7SyBKmNVM",
        13: "https://youtube.com/shorts/TmWhETCFHSE",
        14: "https://youtube.com/shorts/-5DgY7gn7Hg",
        15: "https://youtube.com/shorts/Bsqy56aq82s",
    }
    
    # Start Date: Day 1 was 2026-10-24
    base_start_date = datetime(2026, 10, 24, 17, 30, 0)
    
    output_items = []
    
    for cday in CAMPAIGN_DAYS:
        day_num = cday["day"]
        day_str = str(day_num)
        
        cloud_item = cloud_data.get(day_str, {})
        video_url = cloud_item.get("cloudinary_url")
        if not video_url:
            print(f"Warning: No video url for day {day_num}")
            continue
            
        release_dt = base_start_date + timedelta(days=(day_num - 1))
        
        reel_meta = cday.get("reel", {})
        
        item = {
            "id": day_num,
            "title": cday.get("title", f"اليوم {day_num}"),
            "surah": cday.get("surah", 1),
            "ayah": cday.get("ayah", 1),
            "screen_key": cday.get("screen_key", "quran"),
            "feature_badge": cday.get("feature_badge", "سكن الروح"),
            "hook_text": reel_meta.get("hook_text", ""),
            "ayah_text": reel_meta.get("ayah_text", ""),
            "video_url": video_url,
            "release_date": release_dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "youtube_url": youtube_shorts_map.get(day_num, "https://www.youtube.com/@SakanAl-Rooh"),
            "instagram_url": "https://www.instagram.com/sakan.alrooh.app",
            "tiktok_url": "https://www.tiktok.com/@sakan.alrooh.app",
            "facebook_url": "https://www.facebook.com/profile.php?id=61595603427400"
        }
        output_items.append(item)
        
    out_dir = os.path.join(project_root, "assets", "data")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "spiritual_reels.json")
    
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(output_items, f, ensure_ascii=False, indent=2)
        
    print(f"Successfully generated {len(output_items)} spiritual reels into {out_path}")

if __name__ == "__main__":
    main()

