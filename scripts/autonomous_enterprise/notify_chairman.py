# -*- coding: utf-8 -*-
"""
إشعار رئيس مجلس الإدارة والمالك عبر التيليجرام بتمام التنفيذ البرمجي
"""

import os
import sys
import json
import urllib.request

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(CURRENT_DIR, "config.json")
ORDERS_PATH = os.path.join(CURRENT_DIR, "chairman_orders.json")

def notify_chairman(message_text):
    if not os.path.exists(CONFIG_PATH):
        print("Config not found")
        return False

    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        config = json.load(f)

    bot_token = config.get("bot_token")
    chat_id = config.get("chairman_chat_id")

    if not bot_token or not chat_id:
        print("Bot token or chat_id not found")
        return False

    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": f"🤖 **تقرير التنفيذ البرمجي من بيئة التطوير (IDE):**\n\n{message_text}",
        "parse_mode": "Markdown"
    }

    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            res = json.loads(resp.read().decode("utf-8"))
            if res.get("ok"):
                print("Notification sent successfully to Chairman via Telegram!")
                return True
            else:
                print(f"Telegram error: {res}")
                return False
    except Exception as e:
        print(f"Error notifying Chairman: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        msg = " ".join(sys.argv[1:])
        notify_chairman(msg)
    else:
        notify_chairman("تم فحص وتأكيد جاهزية الاتصال المباشر بين بيئة التطوير وتيليجرام بنجاح! 🚀")
