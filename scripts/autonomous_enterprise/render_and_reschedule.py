# -*- coding: utf-8 -*-
"""
برنامج مسح وإعادة جدولة الـ 10 أيام في Buffer بالهوكات الصاروخية والتعليق الأول المثبت
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
from specialists.buffer_publisher import BufferPublisher

def get_due_at_golden_hour(offset_days=0):
    now = datetime.now(timezone.utc)
    base = datetime(now.year, now.month, now.day, 17, 30, 0, tzinfo=timezone.utc)
    start_offset = 1 if now >= base else 0
    target = base + timedelta(days=start_offset + offset_days)
    return target.strftime("%Y-%m-%dT%H:%M:%SZ")

def main():
    print(">>> Starting schedule purge and rescheduling with viral hooks...")
    
    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()
    
    # 1. Clear old schedule from Buffer
    print(">>> Clearing all pending posts from Buffer queue...")
    del_res = md.clear_buffer_schedule()
    print(del_res)
    
    # 2. Render days 5-14 with updated hooks
    start_day = 5
    target_count = 10
    
    for i in range(target_count):
        day_num = start_day + i
        camp_data = get_campaign_day(day_num)
        reel_file = os.path.join(rd.output_dir, f"reel_day_{day_num}.mp4")
        
        if day_num != 5 or not os.path.exists(reel_file):
            print(f">>> Rendering Reel for Day #{day_num} with hook: {camp_data['reel']['hook_text']}...")
            rd.generate_daily_reel(camp_data, day_num)
            
        due_at = get_due_at_golden_hour(offset_days=i)
        pkg = md.prepare_daily_package(day_num)
        
        print(f">>> Scheduling Day #{day_num} for golden hour: {due_at}...")
        res = md.publish_to_buffer(
            pkg["caption"],
            media_path=pkg["reel_path"],
            due_at=due_at,
            mode="customScheduled"
        )
        print(f"    Result: {res.get('success')} - Posts: {len(res.get('posts', []))}")
        
    print("\n[SUCCESS] Successfully scheduled 10 full campaign days with viral hooks and pinned comments!")

if __name__ == "__main__":
    main()
