# -*- coding: utf-8 -*-
"""
صانع الستوريز الإسلامية الفاخرة (Islamic Story Director)
يولد بطاقات ستوري عمودية عالية الدقة (1080x1920) بنقوش إسلامية وزوايا ذهبية لنشرها على إنستغرام وفيسبوك
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

def shape_ar(text):
    if not text:
        return ""
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

class StoryDirector:
    def __init__(self):
        self.output_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "output")
        os.makedirs(self.output_dir, exist_ok=True)
        self.font_title_path = "C:/Windows/Fonts/tradbdo.ttf"
        self.font_sub_path = "C:/Windows/Fonts/tahomabd.ttf"

    def _get_font(self, path, size):
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            return ImageFont.load_default()

    def generate_story_card(self, story_data, day_num=1):
        """توليد بطاقة ستوري احترافية متكاملة 1080x1920"""
        width, height = 1080, 1920
        # Background gradient: deep midnight emerald
        img = Image.new("RGBA", (width, height), (7, 26, 20, 255))
        draw = ImageDraw.Draw(img)

        # Subtle emerald radial vignette
        center_x, center_y = width // 2, height // 2
        for r in range(width, 0, -40):
            alpha = int(45 * (1 - r / width))
            draw.ellipse([center_x - r, center_y - r, center_x + r, center_y + r], fill=(16, 75, 55, alpha))

        # Golden outer frame & ornamental corners
        pad = 60
        draw.rounded_rectangle([pad, pad, width - pad, height - pad], radius=40, outline=(212, 175, 55, 140), width=3)
        draw.rounded_rectangle([pad + 12, pad + 12, width - pad - 12, height - pad - 12], radius=32, outline=(212, 175, 55, 60), width=1)

        # Ornamental header
        font_header = self._get_font(self.font_title_path, 60)
        font_verse = self._get_font(self.font_title_path, 54)
        font_text = self._get_font(self.font_sub_path, 34)
        font_badge = self._get_font(self.font_sub_path, 28)

        # Title
        title_text = shape_ar(story_data.get("headline", "نفحة إيمانية 🌙"))
        draw.text((width // 2, 280), title_text, fill=(245, 218, 125), font=font_header, anchor="mm")

        # Decorative divider line with diamond
        draw.line([width // 2 - 200, 360, width // 2 + 200, 360], fill=(212, 175, 55, 180), width=2)
        draw.polygon([(width // 2, 350), (width // 2 + 10, 360), (width // 2, 370), (width // 2 - 10, 360)], fill=(245, 218, 125))

        # Central Verse / Zekr Box (Glassmorphic)
        box_y1, box_y2 = 520, 1080
        box_x1, box_x2 = 120, width - 120
        draw.rounded_rectangle([box_x1, box_y1, box_x2, box_y2], radius=30, fill=(13, 48, 38, 200), outline=(212, 175, 55, 100), width=2)

        # Verse Text
        verse_lines = story_data.get("verse", "").split("\n")
        cur_y = 660
        for line in verse_lines:
            v_text = shape_ar(line.strip())
            draw.text((width // 2, cur_y), v_text, fill=(255, 255, 255), font=font_verse, anchor="mm")
            cur_y += 85

        # Tip / Reflection Box
        tip_text = shape_ar(story_data.get("tip", ""))
        draw.text((width // 2, 1220), tip_text, fill=(210, 235, 225), font=font_text, anchor="mm")

        # App Icon & Branding at Bottom
        icon_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), "store_assets", "app_icon_512x512.png")
        if os.path.exists(icon_path):
            try:
                icon = Image.open(icon_path).convert("RGBA").resize((160, 160), Image.Resampling.LANCZOS)
                # Round icon corners
                mask = Image.new("L", (160, 160), 0)
                mask_draw = ImageDraw.Draw(mask)
                mask_draw.rounded_rectangle([0, 0, 160, 160], radius=40, fill=255)
                icon.putalpha(mask)
                img.paste(icon, (width // 2 - 80, 1420), icon)
            except Exception:
                pass

        tag_text = shape_ar(story_data.get("tag", "تطبيق سكن الروح 🌙 واحتك الإيمانية النقية"))
        draw.text((width // 2, 1640), tag_text, fill=(245, 218, 125), font=font_badge, anchor="mm")

        cta_text = shape_ar("بدون أي إعلانات نهائياً • متاح مجاناً على Google Play و Huawei")
        draw.text((width // 2, 1700), cta_text, fill=(180, 205, 195), font=self._get_font(self.font_sub_path, 24), anchor="mm")

        out_path = os.path.join(self.output_dir, f"story_day_{day_num}.png")
        img.convert("RGB").save(out_path, quality=95)
        return out_path
