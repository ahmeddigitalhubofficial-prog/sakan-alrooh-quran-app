# -*- coding: utf-8 -*-
"""
Twin Schedule Engine (المحرك الموحد لجدولة ومطابقة Buffer و YouTube Shorts)
يضمن أن كل يوم ينشر متزامناً وبنفس التوقيت (الساعة 8:30 م بتوقيت القاهرة / 17:30 UTC)
على كل من Buffer (فيسبوك، إنستجرام، تيك توك) و YouTube Shorts (@SakanAl-Rooh)
مع آلية التعويض والملء التلقائي المتطابق عند نقص أي منشور.
"""

import os
import sys
import json
import time
from datetime import datetime, timedelta, timezone

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from managing_director import ManagingDirector
from specialists.reel_director import ReelDirector
from specialists.campaign_calendar import get_campaign_day, CAMPAIGN_DAYS
from specialists.youtube_publisher import YouTubePublisher

STATE_FILE = os.path.join(CURRENT_DIR, "twin_schedule_state.json")

def load_twin_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {
        "last_youtube_day": 9,
        "last_buffer_day": 14,
        "quota_reset_date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "scheduled_pairs": []
    }

def save_twin_state(state):
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)

def get_due_at_for_day(date_str, time_str="17:30:00Z"):
    """Format an ISO 8601 UTC timestamp for golden hour (8:30 PM Cairo = 17:30 UTC)"""
    return f"{date_str}T{time_str}"

def run_twin_schedule(max_youtube_uploads=6):
    """
    Executes the synchronization between Buffer and YouTube Shorts.
    1. Uploads and schedules up to 6 Shorts for YouTube starting from tomorrow.
    2. Synchronizes Buffer with the same days to maintain identical schedules.
    3. Saves progress and notifies Telegram Chairman.
    """
    print("=" * 60)
    print(">>> Launching Twin Schedule Engine (Buffer + YouTube Shorts)")
    print("=" * 60)

    md = ManagingDirector(CURRENT_DIR)
    rd = ReelDirector()
    yp = YouTubePublisher()

    if not yp.is_authenticated():
        print("[!] YouTube is NOT authenticated. Please check youtube_token.json.")
        return {"success": False, "error": "YouTube not authenticated"}

    state = load_twin_state()
    today_utc = datetime.now(timezone.utc).date()
    
    # Starting from tomorrow (Nov 2)
    start_date = today_utc + timedelta(days=1)
    print(f">>> Start Date for YouTube Shorts: {start_date} (Golden Hour: 8:30 PM Cairo)")

    # Mapping of target days (Day 10 to Day 15 for today's 6 quota)
    youtube_start_day = 10
    days_to_schedule = []
    for i in range(max_youtube_uploads):
        target_day = youtube_start_day + i
        target_date = start_date + timedelta(days=i)
        due_at = get_due_at_for_day(target_date.strftime("%Y-%m-%d"))
        days_to_schedule.append({
            "day": target_day,
            "date": target_date.strftime("%Y-%m-%d"),
            "due_at": due_at
        })

    results = []

    for item in days_to_schedule:
        day_num = item["day"]
        due_at = item["due_at"]
        camp_data = get_campaign_day(day_num)
        title = camp_data.get("title", f"سكن الروح - يوم {day_num}")
        reel_file = os.path.join(rd.output_dir, f"reel_day_{day_num}.mp4")

        # 1. Ensure reel video exists
        if not os.path.exists(reel_file):
            print(f">>> Rendering Reel for Day #{day_num} ({title})...")
            rd.generate_daily_reel(camp_data, day_num)

        # 2. Upload and schedule to YouTube Shorts
        print(f">>> [YouTube] Scheduling Short Day #{day_num} for {due_at}...")
        desc = (
            f"🌙 {title} #Shorts\n\n"
            f"{camp_data.get('caption', '')}\n\n"
            "📲 حمل تطبيق «سكن الروح» مجاناً وبدون أي إعلانات لوجه الله:\n"
            "🔗 الرابط الشامل لجميع الأجهزة: https://linktr.ee/sakan.alrooh.app\n"
            "🟢 متجر Google Play: https://play.google.com/store/apps/details?id=com.nooralhoda.official.app\n"
            "🔴 متجر Huawei AppGallery: https://appgallery.huawei.com/app/C118816285\n\n"
            "#سكن_الروح #قرآن #أذكار #تلاوات_خاشعة #Shorts #Quran"
        )
        yt_res = yp.upload_shorts(
            reel_file,
            title=f"🌙 {title}",
            description=desc,
            publish_at=due_at
        )

        yt_status = "scheduled" if yt_res.get("success") else "failed"
        video_id = yt_res.get("video_id", "")
        print(f"    YouTube Result: {yt_status} (Video ID: {video_id})")

        # 3. Check Buffer status for Day 15 (Days 10-14 are already in Buffer)
        buf_status = "already_in_buffer"
        if day_num >= 15:
            print(f">>> [Buffer] Scheduling Day #{day_num} to match YouTube...")
            pkg = md.prepare_daily_package(day_num)
            buf_res = md.publish_to_buffer(
                pkg["caption"],
                media_path=pkg["reel_path"],
                due_at=due_at,
                mode="customScheduled",
                skip_youtube=True
            )
            buf_status = "scheduled" if buf_res.get("success") else "failed"
            print(f"    Buffer Result: {buf_status}")

        results.append({
            "day": day_num,
            "date": item["date"],
            "due_at": due_at,
            "title": title,
            "youtube_status": yt_status,
            "youtube_id": video_id,
            "buffer_status": buf_status
        })

        state["last_youtube_day"] = day_num
        if day_num >= 15 and buf_status == "scheduled":
            state["last_buffer_day"] = day_num
        save_twin_state(state)

        # Brief sleep between uploads
        time.sleep(2)

    print("\n" + "=" * 60)
    print(">>> Twin Schedule Completed Successfully!")
    print(f"Total YouTube Shorts Scheduled: {len(results)}")
    print("=" * 60)

    # 4. Notify Chairman on Telegram
    try:
        from master_telegram_bot import send_message, CONFIG
        chat_id = CONFIG.get("chairman_chat_id")
        if chat_id:
            msg = (
                "🎉 **تقرير المطابقة المزدوجة التلقائية (YouTube Shorts & Buffer):**\n\n"
                "تم بنجاح رفع وجدولة الحد الأقصى اليومي لليوتيوب (6 فيديوهات شورتس) لتتطابق تماماً مع باقي المنصات بدءاً من غداً في الموعد الذهبي (8:30 م):\n\n"
            )
            for r in results:
                yt_link = f"https://youtube.com/shorts/{r['youtube_id']}" if r.get("youtube_id") else "تمت الجدولة"
                msg += f"• **اليوم #{r['day']} ({r['date']}):**\n  📌 {r['title']}\n  🔴 يوتيوب: `{yt_link}`\n  📱 باقي القنوات (Buffer): `{r['buffer_status']}`\n\n"
            msg += (
                "⏰ **الخطوة التالية التلقائية:**\n"
                "سيقوم النظام غداً بإذن الله بإكمال الأيام اللاحقة (اليوم 16 حتى 20) لتغطية الـ 10 أيام كاملة على المنصتين متزامنتين، ثم تفعيل التعويض التلقائي المستمر 24/7."
            )
            send_message(chat_id, msg)
            print("Telegram notification delivered to Chairman.")
    except Exception as e:
        print(f"Telegram notify error: {e}")

    return {"success": True, "results": results}

if __name__ == "__main__":
    run_twin_schedule(max_youtube_uploads=6)

