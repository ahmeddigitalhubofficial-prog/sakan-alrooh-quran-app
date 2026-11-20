# -*- coding: utf-8 -*-
"""
Generates high-resolution QR codes and promotional cards for Bio, Profile, and Stories:
1. store_assets/qr_code_sakan_clean.png (Ultra-HD transparent QR Code)
2. store_assets/sakan_bio_card_1080x1080.png (Square feed/bio/Linktree card)
3. store_assets/sakan_bio_story_1080x1920.png (9:16 vertical story card)
"""

import os
import qrcode
from PIL import Image, ImageDraw, ImageFont
import arabic_reshaper
from bidi.algorithm import get_display

def shape_ar(text):
    if not text:
        return ""
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    assets_dir = os.path.join(root_dir, "store_assets")
    os.makedirs(assets_dir, exist_ok=True)

    url = "https://linktr.ee/sakan.alrooh.app"
    font_bold = "C:/Windows/Fonts/tradbdo.ttf"
    font_sub = "C:/Windows/Fonts/tahomabd.ttf"

    print("Generating ultra-HD QR Code...")
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=20,
        border=2,
    )
    qr.add_data(url)
    qr.make(fit=True)

    # 1. Clean QR Code
    qr_img = qr.make_image(fill_color="#0A2A20", back_color="#FFFFFF").convert("RGBA")
    clean_qr_path = os.path.join(assets_dir, "qr_code_sakan_clean.png")
    qr_img.save(clean_qr_path, "PNG")
    print(f"Saved: {clean_qr_path}")

    # App Icon
    icon_path = os.path.join(assets_dir, "app_icon_512x512.png")
    app_icon = None
    if os.path.exists(icon_path):
        try:
            icon_raw = Image.open(icon_path).convert("RGBA").resize((160, 160), Image.Resampling.LANCZOS)
            mask = Image.new("L", (160, 160), 0)
            ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (160, 160)], radius=40, fill=255)
            icon_raw.putalpha(mask)
            app_icon = icon_raw
        except Exception as e:
            print("Icon error:", e)

    # 2. Square Bio Card (1080x1080)
    w, h = 1080, 1080
    card = Image.new("RGBA", (w, h), (10, 30, 24, 255))
    draw = ImageDraw.Draw(card)

    # Gradient background
    for y in range(h):
        factor = y / h
        r = int(10 + factor * 8)
        g = int(30 + factor * 28)
        b = int(24 + factor * 22)
        draw.line([(0, y), (w, y)], fill=(r, g, b))

    # Inner decorative border
    draw.rounded_rectangle([(40, 40), (w - 40, h - 40)], radius=36, outline=(218, 180, 75, 180), width=3)

    # Icon
    if app_icon:
        card.paste(app_icon, (w // 2 - 80, 80), app_icon)

    # Headings
    title_font = get_font(font_bold, 52)
    sub_font = get_font(font_sub, 28)
    mini_font = get_font(font_sub, 22)

    t1 = shape_ar("سكن الروح 🌙 واحتك الإيمانية")
    draw.text((w // 2, 280), t1, fill=(245, 218, 125), font=title_font, anchor="mm")

    t2 = shape_ar("بدون أي إعلانات نهائياً • لوجه الله تعالى")
    draw.text((w // 2, 335), t2, fill=(255, 255, 255), font=sub_font, anchor="mm")

    # Center QR Code in a luxurious rounded white box
    qr_display_size = 400
    qr_resized = qr_img.resize((qr_display_size, qr_display_size), Image.Resampling.LANCZOS)
    box_pad = 20
    box_w = qr_display_size + box_pad * 2
    box_h = qr_display_size + box_pad * 2
    box_x = (w - box_w) // 2
    box_y = 390

    draw.rounded_rectangle([(box_x, box_y), (box_x + box_w, box_y + box_h)], radius=28, fill=(255, 255, 255, 255), outline=(218, 180, 75, 255), width=4)
    card.paste(qr_resized, (box_x + box_pad, box_y + box_pad), qr_resized)

    # Call to action text below QR
    cta_main = shape_ar("امسح الكود بكاميرا هاتفك للتحميل المباشر 📲")
    draw.text((w // 2, 885), cta_main, fill=(255, 240, 160), font=get_font(font_bold, 36), anchor="mm")

    cta_bio = shape_ar("أو اضغط على الرابط في البايو أعلى الحساب ☝️")
    draw.text((w // 2, 940), cta_bio, fill=(200, 230, 220), font=sub_font, anchor="mm")

    store_txt = shape_ar("متاح مجاناً على Google Play و Huawei AppGallery")
    draw.text((w // 2, 990), store_txt, fill=(180, 210, 200), font=mini_font, anchor="mm")

    square_path = os.path.join(assets_dir, "sakan_bio_card_1080x1080.png")
    card.save(square_path, "PNG")
    print(f"Saved: {square_path}")

    # 3. Vertical Story Card (1080x1920)
    sw, sh = 1080, 1920
    story = Image.new("RGBA", (sw, sh), (8, 24, 20, 255))
    sdraw = ImageDraw.Draw(story)

    for y in range(sh):
        factor = y / sh
        r = int(8 + factor * 8)
        g = int(24 + factor * 26)
        b = int(20 + factor * 20)
        sdraw.line([(0, y), (sw, y)], fill=(r, g, b))

    sdraw.rounded_rectangle([(40, 60), (sw - 40, sh - 60)], radius=44, outline=(218, 180, 75, 180), width=3)

    if app_icon:
        story.paste(app_icon, (sw // 2 - 80, 180), app_icon)

    st1 = shape_ar("سكن الروح 🌙 واحتك الإيمانية")
    sdraw.text((sw // 2, 390), st1, fill=(245, 218, 125), font=get_font(font_bold, 54), anchor="mm")

    st2 = shape_ar("بدون إعلانات نهائياً • لوجه الله تعالى")
    sdraw.text((sw // 2, 455), st2, fill=(255, 255, 255), font=get_font(font_sub, 32), anchor="mm")

    features = [
        "📖 المصحف المرتل بالرسم العثماني أوفلاين",
        "🕊️ رفيق المشاعر وتسكين القلوب بالقرآن",
        "🕌 مواقيت الصلاة الدقيقة والقبلة بالواقع المعزز",
        "📿 السبحة الذكية مع أذكار الصباح والمساء بالصوت",
        "👨‍👩‍👧‍👦 الختمة التشاركية العائلية برابط ويب مباشر"
    ]
    fy = 550
    for feat in features:
        sdraw.text((sw // 2, fy), shape_ar(feat), fill=(210, 235, 225), font=get_font(font_sub, 28), anchor="mm")
        fy += 60

    # Big QR
    qr_story_size = 480
    qr_st_resized = qr_img.resize((qr_story_size, qr_story_size), Image.Resampling.LANCZOS)
    sbox_pad = 24
    sbox_w = qr_story_size + sbox_pad * 2
    sbox_h = qr_story_size + sbox_pad * 2
    sbox_x = (sw - sbox_w) // 2
    sbox_y = 940

    sdraw.rounded_rectangle([(sbox_x, sbox_y), (sbox_x + sbox_w, sbox_y + sbox_h)], radius=36, fill=(255, 255, 255, 255), outline=(218, 180, 75, 255), width=5)
    story.paste(qr_st_resized, (sbox_x + sbox_pad, sbox_y + sbox_pad), qr_st_resized)

    sdraw.text((sw // 2, 1550), shape_ar("امسح الكود بكاميرا هاتفك للتحميل المباشر 📲"), fill=(255, 240, 160), font=get_font(font_bold, 40), anchor="mm")
    sdraw.text((sw // 2, 1620), shape_ar("أو اضغط الرابط في البايو أعلى الحساب ☝️"), fill=(245, 218, 125), font=get_font(font_sub, 32), anchor="mm")
    sdraw.text((sw // 2, 1680), shape_ar("اكتب (تم) في التعليقات ليصلك رابط التحميل فوراً 💬"), fill=(200, 230, 220), font=get_font(font_sub, 28), anchor="mm")
    sdraw.text((sw // 2, 1750), shape_ar("Google Play • Huawei AppGallery"), fill=(180, 210, 200), font=get_font(font_sub, 26), anchor="mm")

    story_path = os.path.join(assets_dir, "sakan_bio_story_1080x1920.png")
    story.save(story_path, "PNG")
    print(f"Saved: {story_path}")

if __name__ == "__main__":
    main()
