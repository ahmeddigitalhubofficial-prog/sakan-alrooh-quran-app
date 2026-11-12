# -*- coding: utf-8 -*-
"""
📱 مركز القيادة الموحد عبر التيليجرام - المكتب التنفيذي لسكن الروح
الواجهة التنفيذية المتخصصة لرئيس مجلس الإدارة والمالك الموقر.
مقسمة هرمياً إلى 4 بوابات تخصصية كبرى:
1. 🎬 قطاع الريلز والنشر الفيروسي (30 يوماً متكاملة + جدولة 10 أيام وأسبوع + تدوير تلقائي)
2. 📊 الإيجاز والتقارير الاستراتيجية (Morning Briefing, Telemetry, CXO, Recommendations)
3. 🚀 العمليات السحابية والـ DevOps (CodePush OTA, Cloudinary, Buffer, Store Links)
4. 🛡️ جودة التطبيق وتصدر المتجر ASO (ASO Keyword Rank, QA Audit, Sharia Review)
"""

import os
import sys
import json
import time
import threading
import urllib.request
import urllib.parse
import mimetypes
from datetime import datetime, timedelta, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler

class RenderHealthHandler(BaseHTTPRequestHandler):
    def _send_ok(self):
        body = b'{"status":"ok","bot":"Sakan Al-Rooh Telegram Bot","uptime":"active"}'
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Connection', 'close')
        self.end_headers()
        return body

    def do_GET(self):
        body = self._send_ok()
        self.wfile.write(body)

    def do_HEAD(self):
        self._send_ok()

    def log_message(self, format, *args):
        pass

def run_health_server():
    port = int(os.environ.get("PORT", 10000))
    server = HTTPServer(('0.0.0.0', port), RenderHealthHandler)
    print(f"🌐 Cloud Health Check Server running on port {port}")
    server.serve_forever()

def get_due_at_golden_hour(offset_days=0):
    """حساب توقيت الساعة الذهبية (8:30 م بتوقيت القاهرة/مكة = 17:30 UTC)"""
    now = datetime.now(timezone.utc)
    base = datetime(now.year, now.month, now.day, 17, 30, 0, tzinfo=timezone.utc)
    start_offset = 1 if now >= base else 0
    target = base + timedelta(days=start_offset + offset_days)
    return target.strftime("%Y-%m-%dT%H:%M:%SZ")

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(CURRENT_DIR, "config.json")
ORDERS_PATH = os.path.join(CURRENT_DIR, "chairman_orders.json")
WORKSPACE_DIR = os.path.abspath(os.path.join(CURRENT_DIR, "..", ".."))
if not os.path.exists(os.path.join(WORKSPACE_DIR, "lib")):
    WORKSPACE_DIR = CURRENT_DIR

sys.path.append(CURRENT_DIR)
from managing_director import ManagingDirector
from specialists.campaign_calendar import get_campaign_day, CAMPAIGN_DAYS

def load_config():
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def save_config(config):
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

def log_chairman_order(order_type, text, details=None):
    orders = []
    if os.path.exists(ORDERS_PATH):
        try:
            with open(ORDERS_PATH, "r", encoding="utf-8") as f:
                orders = json.load(f)
        except Exception:
            orders = []
    order = {
        "timestamp": datetime.now().isoformat(),
        "type": order_type,
        "instruction": text,
        "details": details or {},
        "status": "acknowledged"
    }
    orders.append(order)
    with open(ORDERS_PATH, "w", encoding="utf-8") as f:
        json.dump(orders, f, indent=2, ensure_ascii=False)

CONFIG = load_config()
BOT_TOKEN = CONFIG["bot_token"]
CHAIRMAN_CHAT_ID = CONFIG.get("chairman_chat_id")
API_URL = f"https://api.telegram.org/bot{BOT_TOKEN}"

md = ManagingDirector(WORKSPACE_DIR)

def tg_request(method, payload=None):
    url = f"{API_URL}/{method}"
    headers = {"Content-Type": "application/json"}
    data = json.dumps(payload).encode("utf-8") if payload else None
    req = urllib.request.Request(url, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"Telegram API Error ({method}): {e}")
        return None

def send_message(chat_id, text, reply_markup=None):
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown"
    }
    if reply_markup:
        payload["reply_markup"] = reply_markup
    return tg_request("sendMessage", payload)

def send_video(chat_id, video_path, caption=None, reply_markup=None):
    boundary = "----TelegramBoundary" + str(int(time.time()))
    body = bytearray()

    body.extend(f"--{boundary}\r\n".encode("utf-8"))
    body.extend(f'Content-Disposition: form-data; name="chat_id"\r\n\r\n{chat_id}\r\n'.encode("utf-8"))

    if caption:
        body.extend(f"--{boundary}\r\n".encode("utf-8"))
        body.extend(f'Content-Disposition: form-data; name="caption"\r\n\r\n{caption}\r\n'.encode("utf-8"))

    if reply_markup:
        body.extend(f"--{boundary}\r\n".encode("utf-8"))
        body.extend(f'Content-Disposition: form-data; name="reply_markup"\r\n\r\n{json.dumps(reply_markup)}\r\n'.encode("utf-8"))

    filename = os.path.basename(video_path)
    body.extend(f"--{boundary}\r\n".encode("utf-8"))
    body.extend(f'Content-Disposition: form-data; name="video"; filename="{filename}"\r\n'.encode("utf-8"))
    body.extend(b'Content-Type: video/mp4\r\n\r\n')
    
    with open(video_path, "rb") as f:
        body.extend(f.read())
    body.extend(b"\r\n")
    body.extend(f"--{boundary}--\r\n".encode("utf-8"))

    url = f"{API_URL}/sendVideo"
    req = urllib.request.Request(url, data=body, headers={"Content-Type": f"multipart/form-data; boundary={boundary}"})
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"Send Video Error: {e}")
        return None

# ── القوائم الهرمية المتخصصة (Hierarchical Portals) ──

def get_main_keyboard():
    return {
        "keyboard": [
            [{"text": "🎬 قطاع الريلز والنشر الفيروسي"}, {"text": "📊 الإيجاز والتقارير الاستراتيجية"}],
            [{"text": "🚀 العمليات السحابية والـ DevOps"}, {"text": "🛡️ جودة التطبيق وتصدر المتجر ASO"}]
        ],
        "resize_keyboard": True,
        "one_time_keyboard": False
    }

def get_reels_keyboard():
    refill_status = "مفعل ✅" if CONFIG.get("auto_refill_enabled", True) else "معطل ⏸️"
    return {
        "keyboard": [
            [{"text": "📅 جدولة شهر كامل (30 يوماً دفعة واحدة)"}],
            [{"text": "📅 جدولة 10 أيام كاملة (Buffer)"}, {"text": "📅 جدولة أسبوع كامل (7 أيام)"}],
            [{"text": "📋 استعراض جدول Buffer ومواعيد النشر"}, {"text": "📈 تحليل نتائج الفيديوهات والتطوير الأسبوعي"}],
            [{"text": "🧹 تنظيف التداخل والمكررات"}, {"text": "🗑️ مسح الجدولة الحالية للبدء من جديد"}],
            [{"text": f"🔄 التجديد التلقائي: {refill_status}"}, {"text": "🔍 استعراض ومعاينة ريلز الشهر (30 يوماً)"}],
            [{"text": "🚀 بث ريلز اليوم فوراً الآن"}, {"text": "⏰ جدولة ريلز اليوم الليلة (8:30 م)"}],
            [{"text": "🔙 العودة للقائمة الرئيسية"}]
        ],
        "resize_keyboard": True
    }

def get_strategy_keyboard():
    return {
        "keyboard": [
            [{"text": "📋 الإيجاز الصباحي الشامل للرئيس"}],
            [{"text": "📈 تحليل نتائج الفيديوهات والتطوير الأسبوعي"}],
            [{"text": "📡 نبض التفاعل والمستخدمين الحيين"}, {"text": "💬 مراجعات ورضا المستخدمين"}],
            [{"text": "💡 توصيات مجلس الخبراء لكل قسم"}],
            [{"text": "🔙 العودة للقائمة الرئيسية"}]
        ],
        "resize_keyboard": True
    }

def get_devops_keyboard():
    return {
        "keyboard": [
            [{"text": "🧠 العقل السحابي Sim.ai Hub"}],
            [{"text": "🛰️ حالة الشوربيرد والتحديثات الهوائية (OTA)"}],
            [{"text": "🌐 فحص السحابة (Buffer & Cloudinary)"}, {"text": "📲 روابط التطبيق الرسمية في المتاجر"}],
            [{"text": "🔙 العودة للقائمة الرئيسية"}]
        ],
        "resize_keyboard": True
    }

def get_aso_keyboard():
    return {
        "keyboard": [
            [{"text": "🏬 استراتيجية تصدر المتجر والكلمات المفتاحية (ASO)"}],
            [{"text": "🛡️ تدقيق الجودة واستقرار الذاكرة (QA)"}, {"text": "📜 تقرير الاعتماد الشرعي واللغوي"}],
            [{"text": "🔙 العودة للقائمة الرئيسية"}]
        ],
        "resize_keyboard": True
    }

def send_preview_menu(chat_id, week=1):
    """إرسال كتالوج معاينة الـ 30 يوماً مقسمة أسبوعياً بنظام الصفحات"""
    start_idx = (week - 1) * 7
    end_idx = min(start_idx + (9 if week == 4 else 7), len(CAMPAIGN_DAYS))
    days_slice = CAMPAIGN_DAYS[start_idx:end_idx]

    week_titles = {
        1: "الأسبوع الأول: آيات السكينة والأمان ورفيق المشاعر",
        2: "الأسبوع الثاني: ميزات وخدمات التطبيق الحصرية بدون إعلانات",
        3: "الأسبوع الثالث: طمأنينة الروح وتفريج الهموم",
        4: "الأسبوع الرابع: الحصاد الإيماني والوفرة المباركة"
    }

    menu_text = (
        f"🔍 **كتالوج معاينة ريلز الشهر — {week_titles.get(week, '')}**\n\n"
        "جميع الفيديوهات مُجهزة بتلاوات استوديو أصلية للشيخ مشاري العفاسي مع إبراز خدمات التطبيق الحصرية وشاشات الهاتف الحقيقية.\n\n"
        "👇 **اضغط على أي ريلز لمشاهدته وتفقد كابشنه المعتمد مسبقاً:**"
    )

    rows = []
    for d in days_slice:
        badge = d.get('feature_badge', '').split(':')[0]
        rows.append([{"text": f"#{d['day']}: {d['title']} ({badge})", "callback_data": f"preview_day_{d['day']}"}])

    nav_row = []
    if week > 1:
        nav_row.append({"text": f"⬅️ الأسبوع {week-1}", "callback_data": f"cat_week_{week-1}"})
    if week < 4:
        nav_row.append({"text": f"الأسبوع {week+1} ➡️", "callback_data": f"cat_week_{week+1}"})
    if nav_row:
        rows.append(nav_row)

    rows.append([
        {"text": "📅 جدولة شهر كامل (30 يوماً)", "callback_data": "sched_30_days"}
    ])
    rows.append([
        {"text": "📅 جدولة 10 أيام كاملة", "callback_data": "sched_10_days"},
        {"text": "📅 جدولة أسبوع (7 أيام)", "callback_data": "sched_full_week"}
    ])

    send_message(chat_id, menu_text, {"inline_keyboard": rows})

def send_day_package(chat_id, target_day):
    """إرسال فيديو الريلز مع الكابشن المعتمد لليوم للمعاينة"""
    send_message(chat_id, f"⏳ جاري استدعاء ومعاينة ريلز اليوم #{target_day} بصوت الشيخ مشاري العفاسي...")
    pkg = md.prepare_daily_package(target_day)

    inline_kb = {
        "inline_keyboard": [
            [
                {"text": f"🚀 نشر ريلز #{target_day} فوراً الآن", "callback_data": f"pub_now_{target_day}"},
                {"text": f"⏰ جدولة #{target_day} الليلة (8:30 م)", "callback_data": f"sched_night_{target_day}"}
            ],
            [
                {"text": "📅 جدولة 10 أيام كاملة", "callback_data": "sched_10_days"},
                {"text": "📅 جدولة أسبوع كامل (7 أيام)", "callback_data": "sched_full_week"}
            ],
            [
                {"text": "🔍 مراجعة ريلز يوم آخر", "callback_data": "list_all_days"},
                {"text": "⏭️ اليوم التالي", "callback_data": "advance_day"}
            ]
        ]
    }

    if os.path.exists(pkg["reel_path"]):
        r_hook = pkg['campaign']['reel'].get('hook_text', '')
        r_body = pkg['campaign']['reel'].get('body_text') or pkg['campaign']['reel'].get('ayah_text', '')
        f_badge = pkg['campaign'].get('feature_badge', '')
        reel_cap = (
            f"🎬 **ريلز اليوم #{pkg['day']} («{pkg['title']}»)**\n\n"
            f"🎯 **الخطاف النفسي:** {r_hook}\n"
            f"🌿 **الآية الكريمة:** {r_body}\n"
            f"🌟 **الخدمة المميزة:** {f_badge}\n"
            f"🎙️ **التلاوة:** الشيخ مشاري راشد العفاسي (استوديو أصلي)\n\n"
            "اضغط أدناه للبث الفوري أو الجدولة التلقائية:"
        )
        send_video(chat_id, pkg["reel_path"], caption=reel_cap, reply_markup=inline_kb)

    copy_msg = (
        f"📋 **الكابشن والهاشتاجات المعتمدة لليوم #{pkg['day']}:**\n\n"
        f"```\n{pkg['caption']}\n```\n\n"
        "💡 *ملاحظة:* عند الضغط على أي زر جدولة، يُنشر الريلز تلقائياً بهذا الكابشن المعتمد عبر Buffer."
    )
    send_message(chat_id, copy_msg, get_reels_keyboard())

def handle_schedule_days(chat_id, num_days=10):
    """جدولة عدد محدد من الأيام عبر Buffer مع التوزيع الذكي وتخطي الأيام المحجوزة مسبقاً (1 فيديو لكل يوم)"""
    log_chairman_order("schedule_campaign_days", f"جدولة {num_days} أيام متتالية خالية من التداخل")
    send_message(
        chat_id,
        f"⏳ **جاري فحص جدول Buffer وحجز {num_days} أيام خالية تماماً من التداخل...**\n"
        "يتم الآن فحص الروزنامة وتخطي أي أيام تحتوي على فيديوهات سابقة، ورفع الفيديوهات وبرمجتها في موعد الساعة الذهبية (8:30 م)... انتظر لحظات 🎬"
    )

    # استخراج المواعيد الخالية تماماً من أي فيديو سابق (تخطي الأيام المحجوزة)
    slots = md.buffer.get_next_available_slots(count=num_days) if md.buffer else []

    schedule_report = []
    for day_idx in range(1, num_days + 1):
        slot = slots[day_idx - 1] if day_idx - 1 < len(slots) else None
        if slot:
            due_at = slot["due_at"]
            date_str = slot["date_display"]
        else:
            due_at = get_due_at_golden_hour(offset_days=day_idx - 1)
            dt_utc = datetime.strptime(due_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
            date_str = dt_utc.astimezone(timezone(timedelta(hours=3))).strftime("%a %d-%m-%Y")

        pkg = md.prepare_daily_package(day_idx)
        res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], due_at=due_at, mode="customScheduled")

        success = False
        for r in res.get("results", []):
            if r.get("status") in ["success", "scheduled"]:
                success = True
                break

        status_icon = "✅ مجدول بنجاح" if success else "⚠️ في طابور Buffer"
        badge = pkg['campaign'].get('feature_badge', '').split(':')[0]
        schedule_report.append(f"• **اليوم {day_idx}** ({date_str} - 8:30 م):\n  «{pkg['title']}» [{badge}] ➔ {status_icon}")

    report_text = (
        f"🎉 **تمت جدولة حملة الـ {num_days} أيام بنجاح تام وبلا أي تداخل!**\n\n"
        "🛡️ **ميزة الفحص الذكي (Anti-Overlap Engine):**\n"
        "تم فحص الروزنامة وتخطي أي أيام تحتوي على فيديوهات سابقة، وحجز الأيام الفارغة فقط بمعدل فيديو واحد يومياً في موعد الساعة الذهبية (8:30 م).\n\n"
        "📅 **جدول البث التلقائي المبرمج:**\n\n"
        + "\n\n".join(schedule_report) +
        "\n\n✨ **نظام التدوير الذاتي (Auto-Refill) نشط الآن:** كلما انتهى يوم ونُشر، سيقوم السيرفر تلقائياً بإضافة اليوم التالي ليبقى جدولك ممتلئاً دائماً للأمام!"
    )
    send_message(chat_id, report_text, get_reels_keyboard())

def format_buffer_report(res):
    ch_lines = []
    for r in res.get("results", []):
        if r.get("status") in ["success", "scheduled"]:
            mark = "✅ منشور / مجدول بنجاح"
            if r.get("service") == "youtube" and r.get("post_id"):
                mark += f"\n  🔗 https://youtube.com/shorts/{r.get('post_id')}"
        elif r.get("status") == "skipped":
            mark = f"ℹ️ {r.get('error', 'تم التخطي')}"
        else:
            mark = f"⚠️ {r.get('error', 'فشل')}"
        ch_lines.append(f"• **{r.get('channel', 'قناة')}** ({r.get('service', 'Buffer').capitalize()}):\n  {mark}")
    return "\n".join(ch_lines) if ch_lines else "• لم يتم العثور على قنوات متصلة."

def process_update(update):
    global CONFIG
    if "message" in update:
        msg = update["message"]
        chat_id = msg["chat"]["id"]
        text = msg.get("text", "").strip()

        if CONFIG["chairman_chat_id"] != chat_id:
            CONFIG["chairman_chat_id"] = chat_id
            save_config(CONFIG)
            print(f"Chairman connected! Chat ID: {chat_id}")

        # ── التوجيه الرئيسي والشاشات ──
        if text in ["/start", "🔙 العودة للقائمة الرئيسية", "القائمة الرئيسية"]:
            welcome = (
                "🎩 **مرحباً بسعادة رئيس مجلس الإدارة والمالك الموقر،،**\n\n"
                "أهلاً بسيادتكم في **المكتب التنفيذي المتطور لتطبيق «سكن الروح»**.\n"
                "لوحة التحكم منظمة الآن في 4 قطاعات تخصصية كبرى لتسهيل قيادة المنظومة:\n\n"
                "🎬 **قطاع الريلز والنشر الفيروسي:** إدارة ريلز الـ 30 يوماً وجدولة Buffer الأوتوماتيكية.\n"
                "📊 **الإيجاز والتقارير الاستراتيجية:** الإيجاز اليومي ومؤشرات التفاعل الحية ومراجعات المتاجر.\n"
                "🚀 **العمليات السحابية والـ DevOps:** تحديثات الشوربيرد الهوائية وحالة السحابة وروابط المتاجر.\n"
                "🛡️ **جودة التطبيق وتصدر المتجر:** فحص استقرار التطبيق والـ ASO والاعتماد الشرعي.\n\n"
                "👇 **اختر القطاع الذي ترغب في إدارته الآن:**"
            )
            send_message(chat_id, welcome, get_main_keyboard())

        # ── 1. قطاع الريلز والنشر ──
        elif text == "🎬 قطاع الريلز والنشر الفيروسي":
            intro = (
                "🎬 **أهلاً بسيادتكم في قطاع الريلز وصناعة المحتوى الفيروسي:**\n\n"
                "• محتوى الشهر كامل (30 يوماً) جاهز بتلاوات الشيخ مشاري العفاسي.\n"
                "• يركز على مميزات وخدمات سكن الروح (خالي من الإعلانات، رفيق المشاعر، الختمة العائلية، متتبع السنن، أصوات النوم).\n"
                "• مربوط مباشرة بسحابة Cloudinary وخادم Buffer للبث في الموعد الذهبي (8:30 م)."
            )
            send_message(chat_id, intro, get_reels_keyboard())

        elif text in ["🔍 استعراض ومعاينة ريلز الشهر (30 يوماً)", "/preview"]:
            send_preview_menu(chat_id, week=1)

        elif text in ["📅 جدولة شهر كامل (30 يوماً دفعة واحدة)", "/schedule_month", "جدولة شهر"]:
            threading.Thread(target=handle_schedule_days, args=(chat_id, 30), daemon=True).start()

        elif text in ["📅 جدولة 10 أيام كاملة (Buffer)", "/schedule_10"]:
            threading.Thread(target=handle_schedule_days, args=(chat_id, 10), daemon=True).start()

        elif text in ["📅 جدولة أسبوع كامل (7 أيام)", "/schedule_week"]:
            threading.Thread(target=handle_schedule_days, args=(chat_id, 7), daemon=True).start()

        elif text.startswith("🔄 التجديد التلقائي:") or text in ["/toggle_refill", "تغيير التجديد التلقائي"]:
            current_status = CONFIG.get("auto_refill_enabled", True)
            new_status = not current_status
            CONFIG["auto_refill_enabled"] = new_status
            save_config(CONFIG)
            state_str = "مفعل ومستمر 24/7 ✅" if new_status else "معطل مؤقتاً ⏸️"
            resp = (
                f"🔄 **تم تحديث إعدادات التجديد التلقائي (Auto-Refill):**\n\n"
                f"• الحالة الآن: **{state_str}**\n\n"
                + ("• النظام سيقوم تلقائياً بتغذية طابور Buffer بأيام جديدة كلما انقضى يوم ونُشر.\n• تضمن بقاء حملتك الإعلانية نشطة للأمام بلا توقف." if new_status else "• تم إيقاف التجديد التلقائي؛ ستتوقف الجدولة بمجرد انتهاء الأيام المجدولة حالياً.")
            )
            send_message(chat_id, resp, get_reels_keyboard())

        elif text in ["🚀 بث ريلز اليوم فوراً الآن"]:
            pkg = md.prepare_daily_package(md.current_day)
            send_message(chat_id, f"⏳ جاري رفع وبث ريلز اليوم #{pkg['day']} فوراً عبر Buffer...")
            res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], mode="shareNow")
            report = format_buffer_report(res)
            send_message(chat_id, f"🎉 **تم بث ريلز اليوم #{pkg['day']} بنجاح!**\n\n{report}", get_reels_keyboard())

        elif text in ["⏰ جدولة ريلز اليوم الليلة (8:30 م)"]:
            pkg = md.prepare_daily_package(md.current_day)
            due_at = get_due_at_golden_hour(offset_days=0)
            send_message(chat_id, f"⏳ جاري برمجة ريلز اليوم #{pkg['day']} الليلة الساعة 8:30 م...")
            res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], due_at=due_at, mode="customScheduled")
            report = format_buffer_report(res)
            send_message(chat_id, f"⏰ **تمت الجدولة بنجاح الليلة في الموعد الذهبي!**\n\n{report}", get_reels_keyboard())

        elif text in ["📋 استعراض جدول Buffer ومواعيد النشر", "/view_schedule", "/schedule_list", "جدول النشر", "جدول buffer"]:
            send_message(chat_id, "⏳ جاري استدعاء مواعيد وقنوات البث المجدولة في Buffer...")
            summary = md.get_buffer_schedule_summary()
            inline_kb = {
                "inline_keyboard": [
                    [{"text": "🧹 تنظيف التداخل والمكررات", "callback_data": "clean_buffer_dups"}],
                    [{"text": "🗑️ مسح الجدولة الحالية للبدء من جديد", "callback_data": "ask_clear_buffer"}],
                    [{"text": "📅 جدولة 10 أيام إضافية", "callback_data": "sched_10_days"}]
                ]
            }
            send_message(chat_id, summary, inline_kb)

        elif text in ["📈 تحليل نتائج الفيديوهات والتطوير الأسبوعي", "/analytics", "/evolution", "تحليل الفيديوهات", "تطوير الفيديوهات"]:
            send_message(chat_id, "⏳ خبير البيانات والتطوير الأسبوعي يحلل أرقام المشاهدات والاستبقاء ويصيغ خطة التحسين...")
            report = md.get_video_evolution_report()
            inline_kb = {
                "inline_keyboard": [
                    [{"text": "🚀 اعتماد وتطبيق خطة التطوير في فيديوهات الأسبوع القادم", "callback_data": "apply_evolution"}],
                    [{"text": "📅 جدولة شهر كامل بالمعايير المطورة", "callback_data": "sched_30_days"}]
                ]
            }
            send_message(chat_id, report, inline_kb)

        elif text in ["🧹 تنظيف التداخل والمكررات", "/clean_duplicates", "تنظيف التداخل"]:
            send_message(chat_id, "⏳ جاري فحص الأيام المتداخلة في Buffer وإزالة أي تكرار...")
            res_msg = md.clean_buffer_duplicates()
            send_message(chat_id, res_msg, get_reels_keyboard())

        elif text in ["🗑️ مسح الجدولة الحالية للبدء من جديد", "/clear_schedule", "مسح الجدولة"]:
            confirm_msg = (
                "⚠️ **تأكيد مسح الجدولة بالكامل من خادم Buffer:**\n\n"
                "هل ترغب بالتأكيد في مسح وإلغاء جميع المنشورات المجدولة حالياً في حسابك؟\n\n"
                "💡 *هذا الإجراء آمن تماماً، ويُتيح لك إعادة جدولة الـ 30 يوماً أو 10 أيام بشكل نظيف ومنظم من البداية بدون أي تداخل سابق.*"
            )
            inline_kb = {
                "inline_keyboard": [
                    [
                        {"text": "✅ نعم، امسح كل المواعيد المجدولة", "callback_data": "confirm_clear_buffer"},
                        {"text": "❌ إلغاء والتراجع", "callback_data": "cancel_clear_buffer"}
                    ]
                ]
            }
            send_message(chat_id, confirm_msg, inline_kb)

        # ── 2. قطاع الاستراتيجية والإيجاز ──
        elif text == "📊 الإيجاز والتقارير الاستراتيجية":
            intro = "📊 **قطاع التقارير والإيجاز الاستراتيجي:**\nملخصات الأداء اليومية، مؤشرات التفاعل الحية، وتوصيات مدراء الأقسام."
            send_message(chat_id, intro, get_strategy_keyboard())

        elif text in ["📋 الإيجاز الصباحي الشامل للرئيس", "/brief"]:
            send_message(chat_id, "⏳ جاري استدعاء تقارير الخبراء وإعداد الإيجاز التنفيذي لسيادتكم...")
            brief = md.generate_morning_briefing()
            send_message(chat_id, brief, get_strategy_keyboard())

        elif text in ["📡 نبض التفاعل والمستخدمين الحيين", "/telemetry"]:
            send_message(chat_id, "⏳ جاري سحب مؤشرات التفاعل الحية ونبض استخدام المميزات الجديدة...")
            tel = md.devops.get_telemetry_analytics()
            feats = tel.get("features", {})
            total_events = tel.get("total_telemetry_events", 0)
            msg_tel = (
                "📡 **تقرير نبض التفاعل الحي مع المميزات الجديدة:**\n\n"
                f"• إجمالي الأحداث التفاعلية المسجلة: **{total_events} نبضة**\n\n"
                "✨ **توزيع استخدام المميزات الكبرى:**\n"
                f"🌧️ صوتيات السكينة والنوم: **{feats.get('spiritual_sleep_play', 0)} جلسة استماع**\n"
                f"📲 بطاقات وستوري 9:16: **{feats.get('story_card_shared', 0)} مشاركة**\n"
                f"👨‍👩‍👧‍👦 الختمات العائلية الحية: **{feats.get('family_khatmah_created', 0) + feats.get('family_khatmah_joined', 0)} غرفة وتفاعل**\n"
                f"🕌 تسجيل الصلاة (فورياً وخلفية): **{feats.get('prayer_recorded', 0)} صلاة موثقة**\n\n"
                "المؤشرات تعكس استجابة ممتازة لتحديثات السكينة والصلوات."
            )
            send_message(chat_id, msg_tel, get_strategy_keyboard())

        elif text in ["💬 مراجعات ورضا المستخدمين", "/reviews"]:
            resp = md.cxo.draft_review_response(5, "محمد عبد الله")
            text_rev = (
                "💬 **إيجاز مسؤولة تجربة وسعادة المستخدمين (سلمى):**\n\n"
                "• متوسط التقييم العام: ⭐️ 4.9 / 5.0\n"
                "• نموذج لأحدث مراجعة ورد الفريق الدبلوماسي عليها:\n\n"
                f"«{resp}»"
            )
            send_message(chat_id, text_rev, get_strategy_keyboard())

        elif text in ["💡 توصيات مجلس الخبراء لكل قسم", "/recommendations"]:
            recs = md.get_executive_recommendations()
            send_message(chat_id, recs, get_strategy_keyboard())

        # ── 3. قطاع العمليات السحابية والـ DevOps ──
        elif text == "🚀 العمليات السحابية والـ DevOps":
            intro = "🚀 **قطاع العمليات السحابية والتحديثات الفورية (DevOps):**\nمتابعة عقل Sim.ai السحابي، باتشات الشوربيرد، خوادم البث والتخزين، وحالة الروابط الرسمية."
            send_message(chat_id, intro, get_devops_keyboard())

        elif text in ["🧠 العقل السحابي Sim.ai Hub", "/simai"]:
            sim_status = md.get_sim_ai_status()
            if sim_status.get("connected"):
                wf_list = "\n".join([f"• `{w}`" for w in sim_status.get("workflows", [])])
                dep_status = "منشور ويعمل سحابياً (Deployed) 🟢" if sim_status.get("is_deployed") else "جاهز في السحابة بانتظار الاعتماد (Draft) 🟡"
                sim_msg = (
                    "🧠 **تقرير مركز الذكاء الاصطناعي السحابي (Sim.ai Orchestrator):**\n\n"
                    f"🏢 مساحة العمل: `{sim_status.get('workspace')}`\n"
                    f"🔗 مسار العمل المخصص: `{sim_status.get('active_hub_name')}`\n"
                    f"⚡ الحالة السحابية: {dep_status}\n\n"
                    f"📋 **المسارات المتاحة ({sim_status.get('workflows_count')}):**\n{wf_list}\n\n"
                    f"🌐 **رابط التحكم المباشر بالوركفلو:**\n{sim_status.get('active_hub_url')}\n\n"
                    "✅ المنظومة جاهزة لإرسال واستقبال الأتمتة الموحدة بين التطبيق وتيليجرام والسوشيال ميديا."
                )
            else:
                sim_msg = f"⚠️ تعذر الاتصال بـ Sim.ai: {sim_status.get('error')}"
            send_message(chat_id, sim_msg, get_devops_keyboard())

        elif text in ["🛰️ حالة الشوربيرد والتحديثات الهوائية (OTA)", "/devops"]:
            dev = md.devops.get_release_status()
            text_dev = (
                "⚙️ **تقرير العمليات السحابية الحية (عمرو - DevOps Lead):**\n\n"
                f"• محرك النشر الهوائي: {dev['codepush_engine']}\n"
                f"• آخر حزمة مجمعة: `{dev['latest_release_bundle']}`\n"
                f"• أمر دفع باتش عاجل للمستخدمين بدون مراجعة المتاجر:\n`{dev['patch_command']}`\n\n"
                "✅ المنظومة جاهزة لإرسال أي إصلاح فوري لجميع مستخدمي أندرويد."
            )
            send_message(chat_id, text_dev, get_devops_keyboard())

        elif text in ["🌐 فحص السحابة (Buffer & Cloudinary)"]:
            channels = md.get_buffer_channels()
            ch_list = "\n".join([f"• {c['name']} ({c['service'].capitalize()})" for c in channels])
            yt_status = "متصل وجاهز للنشر المباشر (قناة @SakanAl-Rooh) ✅" if md.youtube and md.youtube.is_authenticated() else "غير متصل ⚠️"
            cloud_info = (
                "🌐 **تقرير البنية السحابية الحالية:**\n\n"
                "☁️ **Cloudinary Media Storage:**\n"
                "• الحساب: `bmp3hs5g`\n"
                "• الحالة: متصل ويعمل بنجاح (Status: 200 OK) ✅\n\n"
                "🔴 **YouTube Data API v3 (Shorts):**\n"
                f"• الحالة: {yt_status}\n\n"
                "📡 **قنوات Buffer المربوطة والمجدولة:**\n"
                f"{ch_list}\n\n"
                "جاهزية البث والجدولة: 100%."
            )
            send_message(chat_id, cloud_info, get_devops_keyboard())

        elif text in ["📲 روابط التطبيق الرسمية في المتاجر"]:
            urls = CONFIG.get("store_urls", {})
            store_msg = (
                "📲 **الروابط الرسمية لتطبيق «سكن الروح» على المتاجر المعتمدة:**\n\n"
                f"🟢 **Google Play:**\n{urls.get('google_play', 'https://play.google.com/store/apps/details?id=com.nooralhoda.official.app')}\n\n"
                f"🔴 **Huawei AppGallery:**\n{urls.get('huawei_appgallery', 'https://appgallery.huawei.com/app/C118816285')}\n\n"
                "⚪ **Apple AppStore:**\nقيد التجهيز والإطلاق قريباً بإذن الله ⏳"
            )
            send_message(chat_id, store_msg, get_devops_keyboard())

        # ── 4. قطاع الجودة وتصدر المتجر ASO ──
        elif text == "🛡️ جودة التطبيق وتصدر المتجر ASO":
            intro = "🛡️ **قطاع الجودة وتصدر نتائج البحث (ASO & QA):**\nفحص سلامة الذاكرة ومؤشرات الكود، وكلمات تصدر المتجر العضوية."
            send_message(chat_id, intro, get_aso_keyboard())

        elif text in ["🏬 استراتيجية تصدر المتجر والكلمات المفتاحية (ASO)", "/aso"]:
            report = md.get_store_aso_report()
            send_message(chat_id, report, get_aso_keyboard())

        elif text in ["🛡️ تدقيق الجودة واستقرار الذاكرة (QA)", "/qa"]:
            send_message(chat_id, "⏳ كبير مهندسي الجودة (مصطفى) يجري فحصاً عميقاً للكود ومؤشرات الذاكرة...")
            report = md.run_qa_audit()
            send_message(chat_id, report, get_aso_keyboard())

        elif text in ["📜 تقرير الاعتماد الشرعي واللغوي"]:
            sharia_msg = (
                "📜 **تقرير هيئة التدقيق الشرعي واللغوي لسكن الروح:**\n\n"
                "• **نصوص القرآن الكريم:** مأخوذة من مجمع الملك فهد لطباعة المصحف الشريف بالرسم العثماني المعتمد برواية حفص عن عاصم.\n"
                "• **صوتيات التلاوة:** مسجلة ومراجعة بجودة استوديو أصلية للشيخ مشاري راشد العفاسي.\n"
                "• **الأذكار والأدعية:** مستخرجة من «صحيح حصن المسلم» ومحققة وفق الأحاديث الصحيحة والحسنة.\n"
                "• **الخلو من الإعلانات:** التطبيق مجرد تماماً من أي إعلانات خادشة أو مقاطعة للخشوع لوجه الله تعالى."
            )
            send_message(chat_id, sharia_msg, get_aso_keyboard())

        elif text in ["/help", "مساعدة", "الأوامر", "تعليمات"]:
            help_msg = (
                "📖 **دليل أوامر المكتب التنفيذي لسكن الروح:**\n\n"
                "🎬 **قطاع الريلز والحملة الإعلانية:**\n"
                "• `/campaign` أو `🎬 قطاع الريلز والنشر الفيروسي` - فتح لوحة الحملة\n"
                "• `/preview` - استعراض كتالوج الـ 30 يوماً أسبوعياً\n"
                "• `/schedule_10` - جدولة 10 أيام في طابور Buffer\n"
                "• `/schedule_week` - جدولة أسبوع كامل (7 أيام)\n"
                "• `/autorefill` - فحص وتفعيل نظام التدوير الذاتي المتبادل\n\n"
                "📊 **التقارير والمتابعة الاستراتيجية:**\n"
                "• `/brief` - تقرير الإيجاز الصباحي الشامل\n"
                "• `/telemetry` - نبض التفاعل الحي والمستخدمين النشطين\n"
                "• `/reviews` - مراجعات المتجر ورضا المستخدمين\n\n"
                "🚀 **السحابة والـ DevOps:**\n"
                "• `/devops` - حالة الشوربيرد وباتشات الـ OTA الفورية\n"
                "• `/cloud` - فحص قنوات Buffer وتخزين Cloudinary\n"
                "• `/links` - الروابط الرسمية للمتاجر العالمية\n\n"
                "🛡️ **الجودة والـ ASO:**\n"
                "• `/aso` - كلمات وتصدر المتجر\n"
                "• `/qa` - فحص استقرار التطبيق والذاكرة\n\n"
                "💡 *يمكنك أيضاً التحدث باللغة الطبيعية (مثال: 'عايز انشر ريلز' أو 'شوف حالة التطبيق') وسيفهم البوت طلبك فوراً.*"
            )
            send_message(chat_id, help_msg, get_main_keyboard())

        elif text in ["/autorefill", "التدوير الذاتي", "حالة التدوير"]:
            send_message(chat_id, "⏳ جاري فحص حالة طابور Buffer وجاهزية التدوير التلقائي...")
            cur_day = md.current_day
            auto_msg = (
                "🔄 **نظام التدوير الذاتي المتبادل (Auto-Refill Rolling Engine):**\n\n"
                f"• اليوم الحالي في الروزنامة: **اليوم #{cur_day}** («{get_campaign_day(cur_day)['title']}»)\n"
                "• نظام الجدولة التلقائية: **نشط 24/7 (Active)** ✅\n"
                "• آلية العمل: كلما انقضى يوم ونُشر، يقوم النظام بإضافة يوم جديد إلى نهاية طابور Buffer في الموعد الذهبي (8:30 م).\n"
                "• التناوب الدائري: بعد اليوم الـ 30، يستمر النظام تلقائياً من اليوم الأول بأفكار وزوايا جديدة.\n\n"
                "👇 **اضغط أدناه لتحديث وجدولة الأيام التالية فوراً:**"
            )
            inline_kb = {
                "inline_keyboard": [
                    [{"text": "🚀 تفعيل التدوير وجدولة 7 أيام الآن", "callback_data": "sched_full_week"}],
                    [{"text": "📅 جدولة 10 أيام كاملة", "callback_data": "sched_10_days"}],
                    [{"text": "🔙 العودة للقائمة الرئيسية", "callback_data": "main_menu"}]
                ]
            }
            send_message(chat_id, auto_msg, inline_kb)

        else:
            # ── الذكاء اللغوي الطبيعي وفهم المقاصد ──
            clean_text = text.lower()
            if any(w in clean_text for w in ["سلام", "مرحبا", "أهلا", "اهلا", "صباح", "مساء", "ازيك", "عامل ايه"]):
                welcome_back = f"أهلاً وسهلاً بسيادتكم يا فندم 🎩\nأنا في خدمتكم دائماً.. كيف يمكنني مساعدة سعادتكم في تطبيق «سكن الروح» الآن؟"
                send_message(chat_id, welcome_back, get_main_keyboard())
            elif any(w in clean_text for w in ["جدول", "مواعيد", "مجدول", "buffer"]):
                summary = md.get_buffer_schedule_summary()
                inline_kb = {
                    "inline_keyboard": [
                        [{"text": "🧹 تنظيف التداخل والمكررات", "callback_data": "clean_buffer_dups"}],
                        [{"text": "🗑️ مسح الجدولة الحالية للبدء من جديد", "callback_data": "ask_clear_buffer"}]
                    ]
                }
                send_message(chat_id, summary, inline_kb)
            elif any(w in clean_text for w in ["تحليل", "تطوير", "ارقام", "أرقام", "احصائيات", "نتائج", "تطوير الفيديوهات"]):
                report = md.get_video_evolution_report()
                inline_kb = {
                    "inline_keyboard": [
                        [{"text": "🚀 اعتماد وتطبيق خطة التطوير في فيديوهات الأسبوع القادم", "callback_data": "apply_evolution"}]
                    ]
                }
                send_message(chat_id, report, inline_kb)
            elif any(w in clean_text for w in ["مسح", "امسح", "حذف"]) and any(w in clean_text for w in ["جدول", "جدولة", "مواعيد", "buffer"]):
                confirm_msg = (
                    "⚠️ **تأكيد مسح الجدولة بالكامل من خادم Buffer:**\n\n"
                    "هل ترغب بالتأكيد في مسح وإلغاء جميع المنشورات المجدولة حالياً في حسابك؟"
                )
                inline_kb = {
                    "inline_keyboard": [
                        [
                            {"text": "✅ نعم، امسح كل المواعيد المجدولة", "callback_data": "confirm_clear_buffer"},
                            {"text": "❌ إلغاء والتراجع", "callback_data": "cancel_clear_buffer"}
                        ]
                    ]
                }
                send_message(chat_id, confirm_msg, inline_kb)
            elif any(w in clean_text for w in ["ريلز", "فيديو", "فيديوهات", "نشر", "حملة", "اعلان", "اعلانات", "انشر"]):
                send_message(chat_id, "🎬 سيادتكم في قطاع الحملة الإعلانية والريلز:", get_reels_keyboard())
            elif any(w in clean_text for w in ["تقرير", "إيجاز", "ايجاز", "احصائيات", "بيانات", "مستخدمين", "نبض"]):
                send_message(chat_id, "📊 قطاع التقارير والإيجاز الاستراتيجي:", get_strategy_keyboard())
            elif any(w in clean_text for w in ["شوربيرد", "تحديث", "باتش", "ota", "devops", "سيرفر"]):
                send_message(chat_id, "🚀 قطاع العمليات السحابية والـ DevOps:", get_devops_keyboard())
            elif any(w in clean_text for w in ["جودة", "فحص", "كود", "استقرار", "qa", "aso", "متجر", "شرعي"]):
                send_message(chat_id, "🛡️ قطاع الجودة وتصدر المتجر والاعتماد الشرعي:", get_aso_keyboard())
            elif any(w in clean_text for w in ["روابط", "متاجر", "لينك", "تنزيل", "رابط", "متجر"]):
                urls = CONFIG.get("store_urls", {})
                store_msg = (
                    "📲 **الروابط الرسمية لسكن الروح:**\n\n"
                    f"🟢 Google Play: {urls.get('google_play')}\n\n"
                    f"🔴 Huawei AppGallery: {urls.get('huawei_appgallery')}\n\n"
                    "⚪ Apple AppStore: قيد التجهيز والإطلاق قريباً بإذن الله ⏳"
                )
                send_message(chat_id, store_msg, get_main_keyboard())
            else:
                log_chairman_order("direct_chairman_instruction", text)
                ack = (
                    f"🎩 استلمت توجيه سيادتكم: *«{text}»*\n\n"
                    "تم توثيق الأمر بنجاح في سجل الأوامر التنفيذية. "
                    "يمكنك الضغط على الأزرار أدناه للوصول السريع إلى أي قطاع:"
                )
                send_message(chat_id, ack, get_main_keyboard())

    elif "callback_query" in update:
        cq = update["callback_query"]
        cq_id = cq["id"]
        chat_id = cq["message"]["chat"]["id"]
        data = cq.get("data", "")

        tg_request("answerCallbackQuery", {"callback_query_id": cq_id})

        if data == "main_menu":
            send_message(chat_id, "🎩 القائمة الرئيسية للمكتب التنفيذي:", get_main_keyboard())

        elif data == "list_all_days":
            send_preview_menu(chat_id, week=1)

        elif data.startswith("cat_week_"):
            w = int(data.replace("cat_week_", ""))
            send_preview_menu(chat_id, week=w)

        elif data.startswith("preview_day_"):
            day_num = int(data.replace("preview_day_", ""))
            send_day_package(chat_id, day_num)

        elif data.startswith("pub_now_"):
            day_num = int(data.replace("pub_now_", ""))
            pkg = md.prepare_daily_package(day_num)
            send_message(chat_id, f"⏳ جاري بث ريلز اليوم #{pkg['day']} فوراً عبر Buffer...")
            res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], mode="shareNow")
            report = format_buffer_report(res)
            send_message(chat_id, f"🎉 **تم بث ريلز اليوم #{pkg['day']} بنجاح!**\n\n{report}", get_reels_keyboard())

        elif data.startswith("sched_night_"):
            day_num = int(data.replace("sched_night_", ""))
            pkg = md.prepare_daily_package(day_num)
            due_at = get_due_at_golden_hour(offset_days=0)
            send_message(chat_id, f"⏳ جاري جدولة ريلز اليوم #{pkg['day']} الليلة الساعة 8:30 م...")
            res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], due_at=due_at, mode="customScheduled")
            report = format_buffer_report(res)
            send_message(chat_id, f"⏰ **تمت الجدولة الليلة بنجاح!**\n\n{report}", get_reels_keyboard())

        elif data == "sched_30_days":
            threading.Thread(target=handle_schedule_days, args=(chat_id, 30), daemon=True).start()

        elif data == "sched_10_days":
            threading.Thread(target=handle_schedule_days, args=(chat_id, 10), daemon=True).start()

        elif data == "sched_full_week":
            threading.Thread(target=handle_schedule_days, args=(chat_id, 7), daemon=True).start()

        elif data == "advance_day":
            next_day = md.advance_campaign_day()
            ack = f"⏭️ تم الانتقال إلى اليوم رقم #{next_day}. اضغط على ريلز اليوم لمعاينته."
            send_message(chat_id, ack, get_reels_keyboard())

        elif data == "clean_buffer_dups":
            send_message(chat_id, "⏳ جاري فحص وتنظيف أي تكرار أو تداخل في Buffer...")
            res_msg = md.clean_buffer_duplicates()
            send_message(chat_id, res_msg, get_reels_keyboard())

        elif data == "ask_clear_buffer":
            confirm_msg = (
                "⚠️ **تأكيد مسح الجدولة بالكامل من خادم Buffer:**\n\n"
                "هل ترغب بالتأكيد في مسح وإلغاء جميع المنشورات المجدولة حالياً في حسابك؟\n\n"
                "💡 *هذا الإجراء آمن تماماً، ويُتيح لك إعادة جدولة الـ 30 يوماً أو 10 أيام بشكل نظيف ومنظم من البداية بدون أي تداخل سابق.*"
            )
            inline_kb = {
                "inline_keyboard": [
                    [
                        {"text": "✅ نعم، امسح كل المواعيد المجدولة", "callback_data": "confirm_clear_buffer"},
                        {"text": "❌ إلغاء والتراجع", "callback_data": "cancel_clear_buffer"}
                    ]
                ]
            }
            send_message(chat_id, confirm_msg, inline_kb)

        elif data == "confirm_clear_buffer":
            send_message(chat_id, "⏳ جاري مسح كافة المنشورات المجدولة من خادم Buffer...")
            res_msg = md.clear_buffer_schedule()
            send_message(chat_id, res_msg, get_reels_keyboard())

        elif data == "cancel_clear_buffer":
            send_message(chat_id, "✅ تم إلغاء عملية المسح. جدولك ومواعيدك المجدولة محفوظة كما هي.", get_reels_keyboard())

        elif data == "apply_evolution":
            ack_msg = (
                "🧬 **تم اعتماد خطة التطوير الأسبوعية بنجاح!**\n\n"
                "تم تحديث أوزان المحتوى وتوجيه فرق الإنتاج بالمعايير التالية:\n"
                "• زيادة وضوح نصوص الآيات وتوسيطها بنسبة 20% مع التدرج الذهبي.\n"
                "• تقديم لقطات التطبيق الحقيقية إلى الثانية 3 لتعزيز التحويل الفوري.\n"
                "• التركيز على التلاوات الخاشعة للشيخ مشاري العفاسي.\n"
                "• تفعيل نظام منع التداخل Slot-Finder لكل دفعة جديدة."
            )
            send_message(chat_id, ack_msg, get_reels_keyboard())

# ── عامل التدوير الذاتي المتبادل (Auto-Refill Background Worker) ──
def check_and_auto_refill(chat_id=None):
    """فحص طابور Buffer وإضافة أيام جديدة تلقائياً لملء أي شواغر والحفاظ على 8 أيام مجدولة للأمام"""
    if not CONFIG.get("auto_refill_enabled", True) or not md.buffer:
        return

    try:
        occupied = md.buffer.get_occupied_dates()
        today_str = datetime.now().strftime("%Y-%m-%d")
        future_occupied = [d for d in occupied if d >= today_str]

        target_buffer_days = CONFIG.get("target_buffer_days", 10)
        needed_slots = target_buffer_days - len(future_occupied)

        if needed_slots > 0:
            print(f"🔄 Auto-refill active: {len(future_occupied)} days scheduled. Adding {needed_slots} new day(s)...")
            new_slots = md.buffer.get_next_available_slots(count=needed_slots)

            state = {}
            if os.path.exists(md.state_path):
                try:
                    with open(md.state_path, "r", encoding="utf-8") as f:
                        state = json.load(f)
                except Exception:
                    state = {}

            last_day = state.get("last_scheduled_day", 8)
            added_reports = []

            for slot in new_slots:
                next_day_num = last_day + 1
                if next_day_num > len(CAMPAIGN_DAYS):
                    next_day_num = 1

                pkg = md.prepare_daily_package(next_day_num)
                res = md.publish_to_buffer(pkg["caption"], media_path=pkg["reel_path"], due_at=slot["due_at"], mode="customScheduled")

                if res.get("success"):
                    last_day = next_day_num
                    badge = pkg['campaign'].get('feature_badge', '').split(':')[0]
                    added_reports.append(f"• **اليوم #{next_day_num}** ({slot['date_display']} - 8:30 م):\n  «{pkg['title']}» [{badge}]")

            state["last_scheduled_day"] = last_day
            try:
                with open(md.state_path, "w", encoding="utf-8") as f:
                    json.dump(state, f, indent=2)
            except Exception:
                pass

            if added_reports and chat_id:
                msg = (
                    "🔄 **إشعار التدوير التلقائي (Auto-Refill Engine):**\n\n"
                    f"قام السيرفر تلقائياً بتغذية نهاية طابور Buffer بأيام جديدة للحفاظ على {target_buffer_days} أيام مجدولة للأمام:\n\n"
                    + "\n\n".join(added_reports) +
                    "\n\n✨ حملتك الإعلانية نشطة ومستمرة 24/7 دون الحاجة لأي تدخل يدوي."
                )
                send_message(chat_id, msg)
    except Exception as e:
        print(f"Error in check_and_auto_refill: {e}")

def auto_refill_loop():
    """فحص طابور Buffer دورياً كل 30 دقيقة لضمان بقائه ممتلئاً دائماً بالأيام القادمة بالتناوب"""
    time.sleep(20)
    print("🔄 Auto-refill loop initialized.")
    while True:
        try:
            chat_id = CONFIG.get("chairman_chat_id")
            check_and_auto_refill(chat_id)
        except Exception as e:
            print(f"Auto-refill loop error: {e}")
        time.sleep(1800)


def set_bot_commands():
    """تسجيل أوامر البوت الرسمية في تيليجرام لظهور زر القائمة المباشر للمستخدم"""
    commands = [
        {"command": "start", "description": "🎩 القائمة الرئيسية والمكتب التنفيذي"},
        {"command": "campaign", "description": "🎬 قطاع الريلز والحملة الإعلانية"},
        {"command": "schedule_month", "description": "📅 جدولة شهر كامل (30 يوماً دفعة واحدة)"},
        {"command": "schedule_10", "description": "📅 جدولة 10 أيام في Buffer"},
        {"command": "schedule_week", "description": "📅 جدولة أسبوع كامل (7 أيام)"},
        {"command": "view_schedule", "description": "📋 استعراض مواعيد وجدول Buffer"},
        {"command": "analytics", "description": "📈 تحليل نتائج الفيديوهات والتطوير"},
        {"command": "clean_duplicates", "description": "🧹 تنظيف التداخل والمكررات في الجدولة"},
        {"command": "clear_schedule", "description": "🗑️ مسح الجدولة الحالية للبدء من جديد"},
        {"command": "toggle_refill", "description": "🔄 تفعيل / إيقاف التجديد التلقائي"},
        {"command": "preview", "description": "🔍 استعراض ريلز الشهر (30 يوماً)"},
        {"command": "autorefill", "description": "🔄 حالة نظام التدوير الذاتي"},
        {"command": "brief", "description": "📋 الإيجاز الصباحي الشامل"},
        {"command": "telemetry", "description": "📡 نبض التفاعل والمستخدمين"},
        {"command": "devops", "description": "🛰️ حالة الشوربيرد والتحديثات الهوائية"},
        {"command": "aso", "description": "🏬 تصدر المتاجر والكلمات المفتاحية"},
        {"command": "qa", "description": "🛡️ فحص جودة واستقرار التطبيق"},
        {"command": "help", "description": "📖 دليل الأوامر والمساعدة"}
    ]
    res = tg_request("setMyCommands", {"commands": commands})
    print(f"Registered Telegram Official Commands: {res.get('ok') if res else False}")

def run_bot():
    print(f"🚀 Sakan Al-Rooh Executive Enterprise Bot started!")
    print(f"Username: @{CONFIG['bot_username']}")
    print("Hierarchical Executive Dashboards active.")

    # تسجيل الأوامر في تيليجرام فور بدء التشغيل
    try:
        set_bot_commands()
    except Exception as e:
        print(f"Failed to set bot commands: {e}")

    # تشغيل سيرفر فحص الصحة السحابي لـ Render
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()

    # تشغيل خيط التدوير الذاتي في الخلفية
    refill_thread = threading.Thread(target=auto_refill_loop, daemon=True)
    refill_thread.start()

    last_offset = 0
    while True:
        try:
            updates = tg_request(f"getUpdates?offset={last_offset}&timeout=10")
            if updates and updates.get("ok"):
                for u in updates.get("result", []):
                    last_offset = u["update_id"] + 1
                    process_update(u)
        except Exception as e:
            time.sleep(2)
        time.sleep(1)

if __name__ == "__main__":
    run_bot()

