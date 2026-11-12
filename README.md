# 🕋 سكن الروح / نور الهدى (Sakan Al-Rooh — Islamic Spiritual Companion)

<p align="center">
  <img src="play_store_feature_graphic_1024x500.png" alt="Sakan Al-Rooh Banner" width="100%" style="border-radius: 12px;" />
</p>

<p align="center">
  <img src="play_store_icon_512x512.png" alt="Sakan Al-Rooh Icon" width="100" style="border-radius: 20px;" /><br/>
  <b>رفيقك الإيماني اليومي — تطبيق إسلامي متكامل فائق الدقة والأناقة</b>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" /></a>
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-teal" />
  <img src="https://img.shields.io/badge/Status-Google%20Play%20Production-success" />
  <img src="https://img.shields.io/badge/Open%20Source-Showcase-blue" />
</p>

---

## 🏛️ System Architecture

```mermaid
graph TD
    UI[Flutter Presentation Layer] --> Core[Core Engine & Services]
    
    subgraph "Spiritual Feature Suite"
        UI --> Quran[Holy Quran Reader - Uthmani Script]
        UI --> Azkar[Smart Azkar & Hisn Al-Muslim]
        UI --> Qibla[Compass & Qibla Direction Finder]
        UI --> Prayer[Adhan & Prayer Times Engine]
        UI --> Sebha[Interactive Digital 3D Sebha]
    end

    subgraph "Core Infrastructure"
        Core --> Audio[Audio Player & Recitation Streamer]
        Core --> Geo[Geolocator & Coordinates Calculator]
        Core --> Storage[Local-First Hive & SharedPreferences]
    end
```

---

## 🌟 أبرز مميزات التطبيق (Key Features)

1. **📖 المصحف الشريف والتلاوات الصوتية**:
   - عرض سور القرآن الكريم كاملة (114 سورة) بالخط العثماني الواضح.
   - استماع لتلاوات كبار القراء مع حفظ العلامات المرجعية والصفحات الأخيرة.

2. **🧭 بوصلة القبلة ومواقيت الصلاة الدقيقة**:
   - حساب فلكي دقيق لمواقيت الصلاة الخمس مع تنبيهات الأذان التلقائية.
   - بوصلة جغرافية تفاعلية موجهة بدقة نحو الكعبة المشرفة وفق إحداثيات GPS الحية.

3. **📿 السبحة الإلكترونية التفاعلية**:
   - محاكاة عداد التسبيح مع استجابة اهتزازية (Haptic Feedback) وعدادات يومية وإحصائيات تسبيح تراكمية.

4. **🛡️ حصن المسلم والأذكار اليومية الذكية**:
   - أذكار الصباح والمساء، أذكار النوم والاستيقاظ، وأدعية مختارة من الكتاب والسنة مع مؤقتات القراءة.

---

## 🛠️ Setup & Local Build

### 1. Prerequisites
- Flutter SDK 3.16+
- Android Studio / VS Code

### 2. Configure Credentials
Copy the safe template files:
```bash
cp android/key.properties.example android/key.properties
cp android/app/google-services.json.example android/app/google-services.json
```

### 3. Run the App
```bash
flutter pub get
flutter run
```
