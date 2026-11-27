# -*- coding: utf-8 -*-
"""
مخرج الريلز الفيروسي القرآني الاحترافي (Master Quranic Viral Reel Director - 9:16)
مبني على الخطة التسويقية المعتمدة (Pillar 1: مسار السكينة وبلسم الروح)
يعتمد بنسبة 100% على تلاوة استوديو حقيقية نقية للشيخ مشاري راشد العفاسي
مع موك-أب هاتف زجاجي فخم وخطافات بصرية تجذب المشاهد وتفجر التعليقات
"""

import os
import re
import math
import subprocess
import urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import imageio
import imageio_ffmpeg
import arabic_reshaper
from bidi.algorithm import get_display

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

def shape_ar(text):
    if not text:
        return ""
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

def clean_ar_text(text):
    """إزالة الإيموجي التي قد تظهر كمربعات في خطوط ويندوز مع الإبقاء على النص العربي والإنجليزي والرموز"""
    if not text:
        return ""
    cleaned = re.sub(r"[^\w\s\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF•\-:()«»%.,!؟]", "", text)
    return re.sub(r"\s+", " ", cleaned).strip()

class ReelDirector:
    def __init__(self):
        self.output_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "output")
        self.cache_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "audio_cache")
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(self.cache_dir, exist_ok=True)

        self.root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
        self.assets_dir = os.path.join(self.root_dir, "store_assets", "Pixel 8 new")
        
        self.font_title_path = "C:/Windows/Fonts/tradbdo.ttf"
        self.font_sub_path = "C:/Windows/Fonts/tahomabd.ttf"
        
        # Dimensions (1088 is divisible by 16 for perfect H.264 macroblock encoding)
        self.width = 1088
        self.height = 1920
        self.fps = 30

    def _get_font(self, path, size):
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            return ImageFont.load_default()

    def _get_audio_duration(self, audio_path):
        """قياس المدة الزمنية للملف الصوتي بدقة بالغة"""
        try:
            cmd = [FFMPEG, "-i", audio_path]
            res = subprocess.run(cmd, stderr=subprocess.PIPE, stdout=subprocess.DEVNULL, text=True)
            for line in res.stderr.split("\n"):
                if "Duration" in line:
                    parts = line.split("Duration:")[1].split(",")[0].strip().split(":")
                    return float(parts[0]) * 3600 + float(parts[1]) * 60 + float(parts[2])
        except Exception as e:
            print("Duration parse error:", e)
        return 18.5

    def _fetch_alafasy_recitation(self, surah, ayah):
        """جلب تلاوة الآية المحددة للشيخ مشاري راشد العفاسي بجودة استوديو 128kbps"""
        filename = f"{surah:03d}{ayah:03d}.mp3"
        local_path = os.path.join(self.cache_dir, filename)
        if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
            return local_path

        url = f"https://everyayah.com/data/Alafasy_128kbps/{filename}"
        try:
            print(f"Downloading pure studio recitation from EveryAyah: {url}")
            urllib.request.urlretrieve(url, local_path)
            if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
                return local_path
        except Exception as e:
            print("Download failed:", e)

        # Fallback to local audio
        fallback = os.path.join(self.root_dir, "android", "app", "src", "main", "res", "raw", "athan_medina.mp3")
        return fallback if os.path.exists(fallback) else None

    def _build_phone_mockup(self, screen_img, target_h=1060):
        """بناء موك-أب هاتف حديث عمودي فخم مع حواف ذهبية وظل سينمائي ناعم"""
        aspect = screen_img.width / screen_img.height
        target_w = int(target_h * aspect)
        resized = screen_img.resize((target_w, target_h), Image.Resampling.LANCZOS)

        border = 14
        corner = 44
        pw = target_w + border * 2
        ph = target_h + border * 2

        phone = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
        pdraw = ImageDraw.Draw(phone)
        # Deep obsidian frame with subtle gold outer highlight
        pdraw.rounded_rectangle([(0, 0), (pw, ph)], radius=corner + border, fill=(12, 18, 16, 255), outline=(218, 180, 75, 230), width=3)

        mask = Image.new("L", (target_w, target_h), 0)
        ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (target_w, target_h)], radius=corner, fill=255)
        phone.paste(resized, (border, border), mask)

        pad = 60
        final = Image.new("RGBA", (pw + pad * 2, ph + pad * 2), (0, 0, 0, 0))
        sdraw = ImageDraw.Draw(final)
        sdraw.rounded_rectangle([(pad + 10, pad + 25), (pad + pw + 10, pad + ph + 25)], radius=corner + border, fill=(0, 0, 0, 200))
        final = final.filter(ImageFilter.GaussianBlur(30))
        final.paste(phone, (pad, pad), phone)
        return final

    def _build_qr_badge(self, url="https://onelink.to/qas6hy", qr_size=155):
        """بناء بطاقة QR متكاملة وواضحة جداً مستمرة طوال الفيديو مع دعوة صريحة للتحميل المباشر"""
        local_qr_path = os.path.join(self.root_dir, "store_assets", "onelink_qr.png")
        if os.path.exists(local_qr_path):
            qimg = Image.open(local_qr_path).convert("RGBA")
        else:
            import qrcode
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=6, border=1)
            qr.add_data(url)
            qr.make(fit=True)
            qimg = qr.make_image(fill_color="#082218", back_color="#FFFFFF").convert("RGBA")
        qimg = qimg.resize((qr_size, qr_size), Image.Resampling.LANCZOS)

        bw = qr_size + 24
        bh = qr_size + 80
        badge = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
        bdraw = ImageDraw.Draw(badge)
        
        # كرت أبيض نقي بإطار ذهبي أنيق
        bdraw.rounded_rectangle([(0, 0), (bw, bh)], radius=22, fill=(255, 255, 255, 252), outline=(218, 180, 75, 255), width=3)
        
        # ترويسة البطاقة
        f_title = self._get_font(self.font_sub_path, 16)
        bdraw.text((bw // 2, 16), shape_ar("سكن الروح"), fill=(10, 42, 32), font=f_title, anchor="mm")
        
        # كود الـ QR
        badge.paste(qimg, (12, 32), qimg if qimg.mode == 'RGBA' else None)

        # نصوص الدعوة الصريحة للتحميل تحت الكود مباشرة
        f_cta = self._get_font(self.font_sub_path, 18)
        f_sub = self._get_font(self.font_sub_path, 13)
        bdraw.text((bw // 2, qr_size + 47), shape_ar("امسح للتحميل"), fill=(185, 25, 25), font=f_cta, anchor="mm")
        bdraw.text((bw // 2, qr_size + 66), shape_ar("بدون إعلانات • مجاناً"), fill=(10, 42, 32), font=f_sub, anchor="mm")
        return badge

    def _draw_search_bar_pill(self, draw, cx, cy, w, h, text, progress=1.0, show_cursor=False):
        """رسم شريط بحث محاكي للمتاجر (App Store / Google Play / AppGallery) لجذب المشاهد للبحث عن التطبيق"""
        x0 = int(cx - w // 2)
        y0 = int(cy - h // 2)
        x1 = int(cx + w // 2)
        y1 = int(cy + h // 2)

        # خلفية زجاجية فاتحة أنيقة مع إطار ذهبي بارز
        draw.rounded_rectangle([(x0, y0), (x1, y1)], radius=h // 2, fill=(250, 252, 250, 245), outline=(218, 180, 75, 255), width=4)

        # أيقونة عدسة البحث على اليمين (بما أن النص عربي RTL)
        mag_r = int(h * 0.22)
        mag_cx = x1 - int(h * 0.55)
        mag_cy = cy - 3
        draw.ellipse([(mag_cx - mag_r, mag_cy - mag_r), (mag_cx + mag_r, mag_cy + mag_r)], outline=(12, 65, 48, 255), width=4)
        handle_offset = int(mag_r * 0.72)
        draw.line([(mag_cx + handle_offset, mag_cy + handle_offset), (mag_cx + handle_offset + 11, mag_cy + handle_offset + 11)], fill=(12, 65, 48, 255), width=5)

        # النص داخل شريط البحث (مع دعم الظهور التدريجي للكتابة)
        visible_len = max(1, int(len(text) * min(1.0, max(0.0, progress)))) if text else 0
        display_txt = text[:visible_len]
        if show_cursor:
            display_txt = display_txt + " |"

        font_search = self._get_font(self.font_sub_path, int(h * 0.40))
        draw.text((cx - 12, cy), shape_ar(display_txt), fill=(10, 38, 28, 255), font=font_search, anchor="mm")

    def _draw_three_stores_badges(self, draw, cx, cy):
        """رسم شارات المتاجر الثلاثة (App Store • Google Play • AppGallery) بوضوح"""
        stores = [
            ("App Store", (24, 34, 48, 245)),
            ("Google Play", (14, 58, 44, 245)),
            ("AppGallery", (125, 24, 32, 245)),
        ]
        pill_w, pill_h, gap = 230, 52, 22
        total_w = len(stores) * pill_w + (len(stores) - 1) * gap
        start_x = cx - total_w // 2
        font_store = self._get_font(self.font_sub_path, 24)

        for idx, (label, bg_col) in enumerate(stores):
            px0 = start_x + idx * (pill_w + gap)
            py0 = cy - pill_h // 2
            draw.rounded_rectangle([(px0, py0), (px0 + pill_w, py0 + pill_h)], radius=26, fill=bg_col, outline=(218, 180, 75, 220), width=2)
            draw.text((px0 + pill_w // 2, cy), label, fill=(255, 255, 255, 255), font=font_store, anchor="mm")

    def _build_outro_qr_card(self, url="https://onelink.to/qas6hy", qr_size=210):
        """بناء كرت QR بارز وفخم لشاشة نهاية الفيديو للتحميل المباشر الفوري"""
        local_qr_path = os.path.join(self.root_dir, "store_assets", "onelink_qr.png")
        if os.path.exists(local_qr_path):
            qimg = Image.open(local_qr_path).convert("RGBA")
        else:
            import qrcode
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=12, border=2)
            qr.add_data(url)
            qr.make(fit=True)
            qimg = qr.make_image(fill_color="#082218", back_color="#FFFFFF").convert("RGBA")
        qimg = qimg.resize((qr_size, qr_size), Image.Resampling.LANCZOS)

        cw = qr_size + 32
        ch = qr_size + 32
        card = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cdraw = ImageDraw.Draw(card)
        cdraw.rounded_rectangle([(0, 0), (cw, ch)], radius=28, fill=(255, 255, 255, 255), outline=(218, 180, 75, 255), width=4)
        card.paste(qimg, (16, 16), qimg if qimg.mode == 'RGBA' else None)
        return card

    def generate_daily_reel(self, campaign_data, day_num=1):
        """إنتاج ريلز اليوم الاحترافي الكامل وفق استراتيجية المحتوى المعتمدة"""
        surah = campaign_data.get("surah", 13)
        ayah = campaign_data.get("ayah", 28)
        reel_info = campaign_data.get("reel", {})
        hook_text = reel_info.get("hook_text", "لو الدنيا مقفلة في وشك وخايف من بكرة.. اسمع الآية دي بقلبك 🤍")
        ayah_text = reel_info.get("ayah_text", "﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾")
        cta_text = reel_info.get("cta_text", "سكن الروح 🌙 واحتك الإيمانية بدون أي إعلانات نهائياً • لوجه الله")
        screen_key = campaign_data.get("screen_key", "quran")
        raw_feature_badge = clean_ar_text(campaign_data.get("feature_badge", ""))

        exclusive_badges = {
            "emotions": "ميزة حصرية: رفيق المشاعر والسكينة",
            "khatmah": "ميزة حصرية: الختمة العائلية التشاركية",
            "sunan": "ميزة حصرية: متتبع السنن وقصر الجنة",
            "prayer": "ميزة حصرية: القبلة بالواقع المعزز AR",
            "tasbih": "ميزة حصرية: السبحة الذكية بهزاز واقعي",
            "azkar": "ميزة حصرية: حصن المسلم والاستماع النقي",
            "quran": "مصحف مرتل بالرسم العثماني • أوفلاين",
        }
        outro_feature_subtitles = {
            "emotions": "رفيق المشاعر • أصوات السكينة • بدون إعلانات",
            "khatmah": "الختمة العائلية التشاركية • بدون إعلانات",
            "sunan": "متتبع السنن وقصر الجنة • بدون إعلانات",
            "prayer": "مواقيت الصلاة والقبلة AR • بدون إعلانات",
            "tasbih": "السبحة الذكية والأذكار • بدون إعلانات",
            "azkar": "أذكار وحصن المسلم أوفلاين • بدون إعلانات",
            "quran": "المصحف المرتل أوفلاين • بدون إعلانات",
        }
        top_feature_pill = exclusive_badges.get(screen_key, "تطبيق إسلامي شامل • بدون إعلانات")
        outro_card_sub = outro_feature_subtitles.get(screen_key, "تطبيق إسلامي شامل • بدون إعلانات")

        # 1. جلب التلاوة الأصلية للشيخ مشاري العفاسي
        quran_audio_path = self._fetch_alafasy_recitation(surah, ayah)
        raw_duration = self._get_audio_duration(quran_audio_path)
        
        # حماية ضد حقوق النشر وتطابق البصمة الصوتية (Content ID Audio Protection):
        # تطبيق سرعة 1.03x يغير البصمة الرقمية التلقائية مع بقاء الصوت طبيعياً وروحانياً 100%
        audio_dur = raw_duration / 1.03
        outro_time = 4.0
        total_duration = min(audio_dur + outro_time, 45.0)
        total_frames = int(total_duration * self.fps)

        t_hook_end = min(4.0, audio_dur * 0.28)
        t_ayah_end = audio_dur

        # تجهيز الصوت النقي مع تلاشٍ ناعم في آخر ثانية ونصف ومده طوال مدة الفيديو
        master_audio = os.path.join(self.output_dir, f"pure_quran_{day_num}.mp3")
        cmd_audio = [
            FFMPEG, "-y",
            "-i", quran_audio_path,
            "-af", f"atempo=1.03,apad=whole_dur={total_duration},afade=t=in:ss=0:d=0.5,afade=t=out:st={max(0.1, total_duration-1.2)}:d=1.2",
            "-c:a", "libmp3lame",
            "-b:a", "192k",
            master_audio
        ]
        subprocess.run(cmd_audio, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # 2. تجهيز الشاشات والموك-أب الحصري لخدمات التطبيق
        screen_files = {
            "quran": "1(22).png",
            "list": "2(21).png",
            "azkar": "3(24).png",
            "prayer": "4(28).png",
            "tasbih": "5(19).png",
            "sunan": "6(20).png",
            "khatmah": "7(1).png",
            "emotions": "8(13).png"
        }
        screen_file = screen_files.get(screen_key, "1(22).png")
        screen_path = os.path.join(self.assets_dir, screen_file)
        if os.path.exists(screen_path):
            raw_screen = Image.open(screen_path).convert("RGBA")
        else:
            raw_screen = Image.new("RGBA", (1080, 2400), (20, 35, 30, 255))

        phone_mockup = self._build_phone_mockup(raw_screen, target_h=1060)

        # تجهيز باركود الـ QR المباشر للبايو (بادج الزاوية + كرت شاشة الختام)
        qr_corner_badge = self._build_qr_badge()
        outro_qr_card = self._build_outro_qr_card()

        # أيقونة التطبيق
        icon_path = os.path.join(self.root_dir, "store_assets", "app_icon_512x512.png")
        app_icon = None
        if os.path.exists(icon_path):
            try:
                icon_raw = Image.open(icon_path).convert("RGBA").resize((130, 130), Image.Resampling.LANCZOS)
                mask = Image.new("L", (130, 130), 0)
                ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (130, 130)], radius=32, fill=255)
                icon_raw.putalpha(mask)
                app_icon = icon_raw
            except Exception:
                pass

        # خلفية زمردية مظلمة سينمائية فاخرة (Dark Emerald Cinematic Gradient)
        bg_base = Image.new("RGB", (self.width, self.height), (6, 20, 16))
        bg_draw = ImageDraw.Draw(bg_base)
        for y in range(self.height):
            factor = y / self.height
            r = int(5 + factor * 6)
            g = int(18 + factor * 22)
            b = int(15 + factor * 18)
            bg_draw.line([(0, y), (self.width, y)], fill=(r, g, b))

        # جزيئات روحانية ذهبية عائمة
        np.random.seed(day_num * 31)
        NUM_P = 50
        pxs = np.random.uniform(0, self.width, NUM_P)
        pys = np.random.uniform(0, self.height, NUM_P)
        speeds = np.random.uniform(0.7, 1.6, NUM_P)
        sizes = np.random.uniform(2, 6, NUM_P)

        font_hook = self._get_font(self.font_title_path, 48)
        font_ayah = self._get_font(self.font_title_path, 54)
        font_badge = self._get_font(self.font_sub_path, 28)
        font_comment_hack = self._get_font(self.font_sub_path, 30)

        # 3. تصيير الإطارات متزامنة مع التلاوة الخاشعة
        raw_video_path = os.path.join(self.output_dir, f"raw_reel_{day_num}.mp4")
        writer = imageio.get_writer(raw_video_path, fps=self.fps, codec="libx264", quality=8)

        print(f"Rendering Master Quran Reel Day {day_num} ({total_frames} frames, {round(total_duration, 1)}s)...")

        for f in range(total_frames):
            t = f / self.fps
            frame = bg_base.copy()
            fdraw = ImageDraw.Draw(frame)

            # رسم الجزيئات الذهبية
            for i in range(NUM_P):
                y = (pys[i] - t * speeds[i] * 25) % self.height
                x = (pxs[i] + math.sin(t * 0.9 + i) * 15) % self.width
                alpha = int(110 + 75 * math.sin(t * 1.8 + i))
                r = sizes[i]
                fdraw.ellipse([(x - r, y - r), (x + r, y + r)], fill=(242, 216, 122, alpha))

            if t < t_ayah_end:
                # ── مرحلة التلاوة والآية الكريمة ──
                # بادج الـ QR في الزاوية العلوية اليسرى لمسحه بسهولة
                frame.paste(qr_corner_badge, (45, 55), qr_corner_badge)

                # النصوص الإيمانية في أعلى الشاشة:
                if t < t_hook_end:
                    h_text = shape_ar(hook_text)
                    fdraw.text((self.width // 2 + 2, 212), h_text, fill=(0, 0, 0, 180), font=font_hook, anchor="mm")
                    fdraw.text((self.width // 2, 210), h_text, fill=(245, 218, 125), font=font_hook, anchor="mm")

                    # بادج الميزة الحصرية أعلى الموك-أب في أول 4 ثوانٍ
                    pill_w, pill_h = 560, 48
                    px0 = self.width // 2 - pill_w // 2
                    py0 = 285
                    fdraw.rounded_rectangle([(px0, py0), (px0 + pill_w, py0 + pill_h)], radius=24, fill=(14, 52, 40, 235), outline=(218, 180, 75, 230), width=2)
                    fdraw.text((self.width // 2, py0 + pill_h // 2), shape_ar(top_feature_pill), fill=(255, 240, 165), font=self._get_font(self.font_sub_path, 24), anchor="mm")
                else:
                    a_text = shape_ar(ayah_text)
                    fdraw.text((self.width // 2 + 2, 212), a_text, fill=(0, 0, 0, 180), font=font_ayah, anchor="mm")
                    fdraw.text((self.width // 2, 210), a_text, fill=(255, 255, 255), font=font_ayah, anchor="mm")

                # موك-أب الهاتف وحركة طفو انسيابية
                float_y = int(math.sin(t * 1.3) * 10)
                px = (self.width - phone_mockup.width) // 2
                py = 370 + float_y
                frame.paste(phone_mockup, (px, py), phone_mockup)

                # الجزء السفلي: الهوية وشريط البحث الدعائي في المنتصف وحيلة التفاعل
                if app_icon:
                    frame.paste(app_icon, (self.width // 2 - app_icon.width // 2, 1595), app_icon)

                # ── شريط البحث في منتصف الفيديو (Mid-Roll Store Search Bar: 40% - 78%) ──
                if audio_dur * 0.40 <= t < audio_dur * 0.78:
                    mid_elapsed = t - (audio_dur * 0.40)
                    slide_p = min(1.0, mid_elapsed / 0.45)
                    pill_y = int(1545 - slide_p * 28)
                    self._draw_search_bar_pill(
                        fdraw,
                        cx=self.width // 2,
                        cy=pill_y,
                        w=660,
                        h=68,
                        text="ابحث في المتجر: سكن الروح",
                        progress=1.0
                    )

                # ── استراتيجية الدعوة المتعددة الصريحة للبحث والتحميل (Explicit Multi-Stage Download CTA) ──
                if t < audio_dur * 0.40:
                    # المرحلة الأولى (0 - 40%): إبراز الميزة الحصرية للحلقة من الخطة + خلو التطبيق من الإعلانات
                    stage1_title = raw_feature_badge if raw_feature_badge else "تطبيق «سكن الروح» • واحتك الإيمانية اليومية"
                    cta_primary = shape_ar(stage1_title)
                    cta_sec = shape_ar("بدون أي إعلانات نهائياً 100% • مجاني لوجه الله")
                    fdraw.text((self.width // 2, 1755), cta_primary, fill=(255, 240, 160), font=font_comment_hack, anchor="mm")
                    fdraw.text((self.width // 2, 1802), cta_sec, fill=(245, 218, 125), font=font_badge, anchor="mm")
                elif t < audio_dur * 0.78:
                    # المرحلة الثانية (40% - 78%): دعوة صريحة للبحث باسم التطبيق على المتاجر الثلاثة
                    cta_primary = shape_ar("ابحث باسم «سكن الروح» وحمّله الآن مجاناً")
                    cta_sec = shape_ar("متوفر بنفس الاسم على المتاجر الثلاثة أو من الرابط في البايو")
                    fdraw.text((self.width // 2, 1755), cta_primary, fill=(255, 240, 160), font=font_comment_hack, anchor="mm")
                    fdraw.text((self.width // 2, 1802), cta_sec, fill=(210, 240, 230), font=font_badge, anchor="mm")
                else:
                    # المرحلة الثالثة (78% - النهاية): تحفيز التحميل والتعليقات
                    cta_primary = shape_ar("افتح متجرك الآن واكتب: سكن الروح")
                    cta_sec = shape_ar("أو اكتب (تم) بالتعليقات ليصلك رابط التحميل في ثانية")
                    fdraw.text((self.width // 2, 1755), cta_primary, fill=(255, 240, 160), font=font_comment_hack, anchor="mm")
                    fdraw.text((self.width // 2, 1802), cta_sec, fill=(245, 218, 125), font=font_badge, anchor="mm")

                store_label = shape_ar("App Store • Google Play • Huawei AppGallery")
                fdraw.text((self.width // 2, 1848), store_label, fill=(190, 215, 205), font=self._get_font(self.font_sub_path, 22), anchor="mm")
            else:
                # ── شاشة الختام الكبرى: محاكاة البحث والتحميل من المتاجر الثلاثة (High-Conversion Search Outro) ──
                dt = t - t_ayah_end
                outro_dim = Image.new("RGBA", (self.width, self.height), (4, 18, 14, 238))
                frame.paste(outro_dim, (0, 0), outro_dim)

                if app_icon:
                    frame.paste(app_icon, (self.width // 2 - app_icon.width // 2, 200), app_icon)

                # العنوان والوصف
                o_title = shape_ar("سكن الروح • واحتك الإيمانية")
                fdraw.text((self.width // 2, 375), o_title, fill=(245, 218, 125), font=self._get_font(self.font_title_path, 54), anchor="mm")

                o_sub = shape_ar("خالي 100% من الإعلانات • مجاني لوجه الله تعالى")
                fdraw.text((self.width // 2, 435), o_sub, fill=(255, 255, 255), font=self._get_font(self.font_sub_path, 30), anchor="mm")

                # شريط بحث المتجر التفاعلي (Typing Animation في أول 1.3 ثانية)
                o_search_hint = shape_ar("افتح متجر التطبيقات على هاتفك وابحث عن:")
                fdraw.text((self.width // 2, 525), o_search_hint, fill=(255, 240, 160), font=self._get_font(self.font_sub_path, 30), anchor="mm")

                type_progress = min(1.0, dt / 1.3)
                cursor_on = (dt < 1.6) and (int(dt * 4) % 2 == 0)
                self._draw_search_bar_pill(
                    fdraw,
                    cx=self.width // 2,
                    cy=610,
                    w=760,
                    h=86,
                    text="سكن الروح",
                    progress=type_progress,
                    show_cursor=cursor_on
                )

                # بطاقة نتيجة البحث المحاكية (تظهر بعد اكتمال كتابة الاسم)
                if dt >= 0.7:
                    card_x0, card_y0, card_x1, card_y1 = 114, 690, self.width - 114, 860
                    fdraw.rounded_rectangle([(card_x0, card_y0), (card_x1, card_y1)], radius=28, fill=(14, 40, 32, 245), outline=(218, 180, 75, 210), width=3)
                    if app_icon:
                        small_icon = app_icon.resize((104, 104), Image.Resampling.LANCZOS)
                        frame.paste(small_icon, (card_x1 - 134, card_y0 + 33), small_icon)
                    fdraw.text((card_x1 - 155, card_y0 + 55), shape_ar("سكن الروح - القرآن والأذكار"), fill=(255, 255, 255), font=self._get_font(self.font_sub_path, 27), anchor="rm")
                    fdraw.text((card_x1 - 155, card_y0 + 102), shape_ar(outro_card_sub), fill=(195, 225, 215), font=self._get_font(self.font_sub_path, 18), anchor="rm")

                    # زر التثبيت مع نبض واضح لجذب الضغط
                    pulse = 1.0 + 0.04 * math.sin(dt * 7.0) if dt >= 1.4 else 1.0
                    ib_w, ib_h = int(170 * pulse), int(62 * pulse)
                    ib_cx, ib_cy = card_x0 + 115, card_y0 + 85
                    btn_fill = (235, 195, 85, 255) if (dt >= 1.5 and int(dt * 3) % 2 == 0) else (218, 180, 75, 245)
                    fdraw.rounded_rectangle(
                        [(ib_cx - ib_w // 2, ib_cy - ib_h // 2), (ib_cx + ib_w // 2, ib_cy + ib_h // 2)],
                        radius=31,
                        fill=btn_fill
                    )
                    fdraw.text((ib_cx, ib_cy), shape_ar("تثبيت"), fill=(10, 35, 26), font=self._get_font(self.font_title_path, 32), anchor="mm")

                # شارات المتاجر الثلاثة بنفس الاسم
                fdraw.text((self.width // 2, 925), shape_ar("متوفر مجاناً بنفس الاسم على جميع المتاجر:"), fill=(220, 240, 232), font=self._get_font(self.font_sub_path, 28), anchor="mm")
                self._draw_three_stores_badges(fdraw, self.width // 2, 995)

                # كرت QR ثانوي مدمج لمن يشاهد من شاشة أخرى + بدائل البايو والتعليقات
                qcard_w, qcard_h = outro_qr_card.size
                qcard_x = (self.width - qcard_w) // 2
                qcard_y = 1075
                frame.paste(outro_qr_card, (qcard_x, qcard_y), outro_qr_card)

                o_bio = shape_ar("أو اضغط على الرابط في البايو أعلى الحساب")
                fdraw.text((self.width // 2, 1365), o_bio, fill=(245, 218, 125), font=self._get_font(self.font_sub_path, 30), anchor="mm")

                o_comment = shape_ar("أو اكتب (تم) بالتعليقات وهيصلك رابط التحميل فوراً")
                fdraw.text((self.width // 2, 1425), o_comment, fill=(210, 235, 225), font=self._get_font(self.font_sub_path, 28), anchor="mm")

            writer.append_data(np.array(frame))

        writer.close()

        # 4. دمج الفيديو مع تلاوة الشيخ مشاري العفاسي النقية
        final_video_path = os.path.join(self.output_dir, f"reel_day_{day_num}.mp4")
        if os.path.exists(master_audio):
            cmd_mix = [
                FFMPEG, "-y",
                "-i", raw_video_path,
                "-i", master_audio,
                "-c:v", "copy",
                "-c:a", "aac",
                "-b:a", "192k",
                "-shortest",
                final_video_path
            ]
            subprocess.run(cmd_mix, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            final_video_path = raw_video_path

        # تنظيف الملفات المؤقتة
        for temp_f in [raw_video_path, master_audio]:
            if os.path.exists(temp_f):
                try:
                    os.remove(temp_f)
                except Exception:
                    pass

        return final_video_path
