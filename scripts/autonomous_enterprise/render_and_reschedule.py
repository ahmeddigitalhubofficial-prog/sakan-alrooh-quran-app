# -*- coding: utf-8 -*-
"""
Autonomous Rescheduling Script:
Re-renders and re-schedules 10 days (Days 15 to 24) in Buffer queue starting from today (Friday 20-11-2026).
Applies:
1. Continuous high-visibility QR badge in top-left.
2. Dynamic 3-stage high-conversion CTAs.
3. Dedicated 3.5s Outro Screen with large QR card and direct download button.
4. Smart link https://onelink.to/qas6hy in captions & comments.
"""
import os
import sys
import json
from datetime import datetime, timedelta, timezone

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from managing_director import ManagingDirector
from specialists.reel_director import ReelDirector
from specialists.campaign_calendar import get_campaign_day

def get_due_at_golden_hour(offset_days=0):
    now = datetime.now(timezone.utc)
    base = datetime(now.year, now.month, now.day, 17, 30, 0, tzinfo=timezone.utc)
    start_offset = 1 if now >= base else 0
    target = base + timedelta(days=start_offset + offset_days)
    return target.strftime("%Y-%m-%dT%H:%M:%SZ")

def main():
    print(">>> Starting schedule purge and rescheduling with new continuous QR badge and multi-stage CTAs...")
    
    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()
    
    # 1. Clear old schedule from Buffer
    print(">>> Clearing all old pending posts from Buffer queue...")
    del_res = md.clear_buffer_schedule()
    print("    Clear Result:", del_res)
    
    # 2. Render and schedule Days 15 to 24 (10 consecutive days)
    start_day = 15
    target_count = 10
    
    for i in range(target_count):
        day_num = start_day + i
        camp_data = get_campaign_day(day_num)
        print(f"\n==========================================")
        print(f">>> Processing Day #{day_num}...")
        print(f"    Hook: {camp_data['reel']['hook_text']}")
        print(f"    Ayah: {camp_data['reel']['ayah_text']}")
        
        # Render reel with new continuous QR badge and multi-stage CTAs
        print(f">>> Rendering Reel for Day #{day_num}...")
        rendered_reel = rd.generate_daily_reel(camp_data, day_num)
        print(f"    Rendered: {rendered_reel}")
            
        due_at = get_due_at_golden_hour(offset_days=i)
        pkg = md.prepare_daily_package(day_num)
        
        print(f">>> Scheduling Day #{day_num} in Buffer for golden hour: {due_at}...")
        res = md.publish_to_buffer(
            pkg["caption"],
            media_path=pkg["reel_path"],
            due_at=due_at,
            mode="customScheduled"
        )
        print(f"    Result: {res.get('success')} - Posts scheduled: {len(res.get('posts', []))}")
        
    print("\n==========================================")
    print(">>> Fetching updated Buffer schedule summary...")
    summary = md.get_buffer_schedule_summary()
    print(summary)
    print("\n[SUCCESS] Successfully scheduled 10 campaign days (Days 15-24) with new permanent QR badges and multi-stage CTAs!")

if __name__ == "__main__":
    main()
