// feature_guide_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class FeatureGuideItem {
  final String title;
  final String category;
  final IconData icon;
  final String steps;
  final String tip;

  const FeatureGuideItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.steps,
    required this.tip,
  });
}

class FeatureGuideScreen extends StatefulWidget {
  const FeatureGuideScreen({super.key});

  @override
  State<FeatureGuideScreen> createState() => _FeatureGuideScreenState();
}

class _FeatureGuideScreenState extends State<FeatureGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FeatureGuideItem> _allGuides = const [
    FeatureGuideItem(
      title: 'بوصلة القبلة بالواقع المعزز (AR) والبوصلة الرقمية 🧭',
      category: 'الصلوات والنوافل',
      icon: Icons.explore_rounded,
      steps:
          '1. افتح تبويب "القبلة" من شريط التنقل السفلي.\n2. إذا توفرت الكاميرا والصلاحية، ستفتح كاميرا الواقع المعزز (AR) موجهة نحو الكعبة مع سهم ثلاثي الأبعاد مجسم يوجهك يميناً ويساراً.\n3. عند مواجهة القبلة تماماً بدقة، يتحول السهم للون الأخضر المتوهج ويهتز الهاتف وتظهر الكعبة المشرفة في السماء.\n4. في الأجهزة التي لا تدعم الكاميرا أو حال عدم منح الصلاحية، يتحول التطبيق تلقائياً إلى وضع البوصلة الرقمية (2D) الأنيق لضمان عملها في كل الظروف.',
      tip: 'احرص على تحريك الهاتف بحركة رقم 8 في الهواء لمعايرة حساس البوصلة في حال كان هناك أي تشويش مغناطيسي.',
    ),
    FeatureGuideItem(
      title: 'متتبع السنن وبناء قصر الجنة 🏰',
      category: 'الصلوات والنوافل',
      icon: Icons.castle_rounded,
      steps:
          '1. ستجد كارت قصر الجنة في الشاشة الرئيسية، شاشة الورد، ونافذة الصلوات.\n2. يتتبع التطبيق الـ 12 ركعة المؤكدة (2 فجر، 4 قبل الظهر، 2 بعد الظهر، 2 بعد المغرب، 2 بعد العشاء).\n3. مع كل ركعة تسجلها، يرتفع عمود في قصر الجنة التفاعلي مع حساب نسبة الإنجاز والصلوات المتبقية.\n4. التسجيل متزامن لحظياً بين كافة شاشات التطبيق.',
      tip: 'قال ﷺ: «مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ».',
    ),
    FeatureGuideItem(
      title: 'استوديو صانع بطاقات وحالات الواتساب 📸',
      category: 'المشاركات والحالات',
      icon: Icons.camera_alt_rounded,
      steps:
          '1. افتح "استوديو البطاقات" من كروت الشاشة الرئيسية أو القائمة الجانبية.\n2. اختر الآية أو الذكر مع إمكانية تعديل النص وتغيير حجم الخط.\n3. اختر المقاس المناسب (حالة واتساب 9:16 أو مربع 1:1 أو عريض 16:9).\n4. حدد الطابع الجمالي المفضل لديك (ذهبي ملكي، زمردي فاخر، ليلي عميق، أو لؤلؤي).\n5. اضغط على زر "مشاركة للحالة والواتساب" لتصدير صورة فائقة الجودة Ultra-HD ونشرها فوراً.',
      tip: 'يمكنك إضافة توقيع "صدقة جارية" ليكون نشرك للأذكار والآيات سبباً في الأجر الدائم.',
    ),
    FeatureGuideItem(
      title: 'عداد الأذكار الجماعي المليوني 📿',
      category: 'الذكر التشاركي',
      icon: Icons.diversity_3_rounded,
      steps:
          '1. ادخل إلى "الأذكار المليونية" لتجد حملات تسبيح جماعية كبرى.\n2. اختر الحملة (مليونية الصلاة على النبي، 100 ألف استغفار، كنز الحوقلة، أو غراس الجنة).\n3. انقر على زر التسبيح النابض لإضافة تسبيحاتك التي تتراكم فورياً مع عداد الأمة.\n4. شارك رابط الحملة عبر الواتساب لدعوة أهلك وأصدقائك لإكمال الهدف المشترك.',
      tip: 'يعمل العداد بكفاءة تامة بدون إنترنت ويحتفظ بمساهماتك الشخصية بدقة.',
    ),
    FeatureGuideItem(
      title: 'إهداء الثواب والصدقة الجارية للمتوفى والمريض 🤲',
      category: 'الصدقات الجارية',
      icon: Icons.volunteer_activism_rounded,
      steps:
          '1. افتح "إهداء الثواب" واضغط على زر (+) لإضافة اسم متوفى أو مريض أو والدين.\n2. اضغط على "دعوتُ له" أو "+10 تسبيحات" لتسجيل الأعمال الصالحة المهداة لروحه.\n3. اضغط على زر المشاركة لتوليد بطاقة إهداء نصية ونشرها في مجموعات العائلة لحثهم على الدعاء له.',
      tip: 'قال ﷺ: «إِذَا مَاتَ ابنُ آدم انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أو عِلْمٍ يُنْتَفَعُ بِهِ، أو وَلَدٍ صَالِحٍ يَدْعُو لَهُ».',
    ),
    FeatureGuideItem(
      title: 'تحدي الصحبة الصالحة والتنافس في الخير 🏆',
      category: 'التحديات الإيمانية',
      icon: Icons.emoji_events_rounded,
      steps:
          '1. افتح "تحدي الصحبة" للاطلاع على مهام اليوم الإيمانية (الفجر، الأذكار، الضحى، تلاوة صفحة، 1000 تسبيحة، بر وصنائع معروف).\n2. حدد المهام المنجزة لتحصل على نقاط حسنات فورية تضاف لرصيدك في متجر زاد المؤمن.\n3. حافظ على سلسلة الأيام المتواصلة (Streaks 🔥) لرفع مرتبتك.\n4. شارك وسام إنجاز اليوم مع أصدقائك عبر الواتساب لتشجيعهم على الطاعة.',
      tip: 'التنافس في الطاعات من أعظم أبواب الثبات، و«الدال على الخير كفاعله».',
    ),
    FeatureGuideItem(
      title: 'سؤال اليوم وتحدي الصديق في المعلومات الإسلامية 🧠',
      category: 'المسابقات والمعرفة',
      icon: Icons.quiz_rounded,
      steps:
          '1. ادخل إلى "سؤال اليوم" لاختبار معلوماتك في السيرة والقرآن والصحابة.\n2. اختر الإجابة الصحيحة لتحصل على +30 حسنة مع قراءة كارت الفائدة والتفسير.\n3. اضغط "تحدَّ صديقك" لمشاركة السؤال عبر الواتساب ومقارنة نتيجتك معه.',
      tip: 'يتجدد السؤال يومياً تلقائياً ليثري حصيلتك الدينية والثقافية.',
    ),
    FeatureGuideItem(
      title: 'مؤقت النوم الذكي لإذاعات القرآن (Sleep Timer) 🌙',
      category: 'التلاوات والإذاعة',
      icon: Icons.snooze_rounded,
      steps:
          '1. أثناء الاستماع لإذاعات القرآن الكريم، اضغط على أيقونة الهلال في أعلى الشاشة.\n2. حدد المدة الزمنية المطلوبة قبل النوم (15 أو 30 أو 45 أو 60 دقيقة).\n3. قبل انتهاء الوقت بـ 30 ثانية، يبدأ الصوت بالانخفاض تدريجياً وبنعومة (Fade-out) حتى يتوقف تماماً دون إيقاظك.',
      tip: 'يساعدك على النوم في سكينة وطمأنينة مع آيات الذكر الحكيم دون استنزاف بطارية الهاتف.',
    ),
    FeatureGuideItem(
      title: 'الختمة التشاركية برابط الويب 👨‍👩‍👧‍👦',
      category: 'القرآن والختمات',
      icon: Icons.groups_rounded,
      steps:
          '1. في "منظم الختمات"، أنشئ ختمة جماعية للعائلة أو الأصدقاء أو صدقة لمتوفى.\n2. شارك الرابط التفاعلي عبر الواتساب.\n3. يمكن لأي شخص الضغط على الرابط ليفتح له المصحف والختمة مباشرة من متصفح هاتفه بدون الحاجة لتحميل التطبيق.\n4. يتم حجز الأجزاء وتحديث نسبة إنجاز الختمة فورا.',
      tip: 'طريقة مثالية لتنظيم ختمات رمضان والعائلة والأصدقاء بكل سهولة.',
    ),
    FeatureGuideItem(
      title: 'التحديث التلقائي المباشر من المتجر 🚀',
      category: 'النظام والتحديثات',
      icon: Icons.system_update_rounded,
      steps:
          '1. يقوم التطبيق بفحص أحدث التحديثات الرسمية على متجر Google Play تلقائياً عند فتحه.\n2. إذا توفر تحديث جديد، يظهر لك إشعار مباشر للتنزيل في الخلفية دون مقاطعة استخدامك.\n3. يمكنك أيضاً الفحص اليدوي في أي وقت من شاشة الإعدادات عبر زر "التحقق من وجود تحديثات للمتجر".',
      tip: 'يضمن لك هذا النظام البقاء دائماً على أحدث إصدار وتلقي الميزات الجديدة فور صدورها.',
    ),
    FeatureGuideItem(
      title: 'شبكة خدمات زاد المؤمن في الشاشة الرئيسية ✨',
      category: 'الشاشة الرئيسية',
      icon: Icons.auto_awesome_rounded,
      steps:
          '1. في الشاشة الرئيسية ستجد قسماً مخصصاً بعنوان "زاد المؤمن والخدمات الحصرية".\n2. يتيح لك الوصول السريع بنقرة واحدة لـ: إذاعات القرآن الحية، رفيق المشاعر، متابع الصيام، حاسبة الزكاة، مسابقة المعرفة، وبطاقات التهنئة.\n3. الكروت تفاعلية وتنقلك فوراً للخدمة مع تأثيرات حركية أنيقة.',
      tip: 'يمكنك الوصول لهذه الخدمات من الشاشة الرئيسية أو القائمة الجانبية أو شاشة الإعدادات.',
    ),
    FeatureGuideItem(
      title: 'متتبع صيام التطوع والنوافل 🌙',
      category: 'الورد والعبادات',
      icon: Icons.brightness_6_rounded,
      steps:
          '1. افتح شاشة "متتبع الصيام" من القائمة الجانبية أو كروت الشاشة الرئيسية.\n2. ستجد تقويماً تفاعلياً يبرز مواعيد صيام الإثنين والخميس، الأيام البيض (13، 14، 15 هـ)، ومناسبات الصيام (عاشوراء، عرفة، الست من شوال).\n3. انقر على يوم الصيام لتسجيله واحتساب إحصائياتك الإيمانية.\n4. فعّل التنبيهات المسبقة للتذكير بنية الصيام قبل الفجر.',
      tip: 'يمكنك أيضاً تتبع أيام قضاء رمضان وكتابة عدد الأيام المتبقية والمكتملة.',
    ),
    FeatureGuideItem(
      title: 'رفيق المشاعر والسكينة الروحية 🕊️',
      category: 'الراحة النفسية',
      icon: Icons.favorite_rounded,
      steps:
          '1. اختر "رفيق المشاعر" من الشاشة الرئيسية أو القائمة الجانبية.\n2. حدد حالتك النفسية الحالية (حزين 🌧️، قلق ومهموم 🌪️، شاكر ومطمئن ☀️، تائه 🧭، نادم ومستغفر 🤲).\n3. سيعرض لك التطبيق باقة مخصصة من آيات السكينة، الأدعية النبوية المستجابة، والقصص الإيمانية التي تثلج الصدر.',
      tip: 'يمكنك الاستماع للتلاوة المصاحبة للآيات ومشاركة الأدعية مع من تحب.',
    ),
    FeatureGuideItem(
      title: 'موسوعة الأحاديث والأربعين النووية 📜',
      category: 'الحديث والسنة',
      icon: Icons.menu_book_rounded,
      steps:
          '1. افتح شاشة "الأحاديث النبوية" من القائمة.\n2. تصفح الأربعين النووية كاملة أو الأحاديث المصنفة حسب الأبواب (الإيمان، الأخلاق، العبادات).\n3. اضغط على أي حديث للاطلاع على نصه الموثق، شرح معاني الكلمات، والفوائد المستنبطة.',
      tip: 'جميع الأحاديث مخرجة ومحققة من أمهات كتب السنة (صحيح البخاري ومسلم والسنن).',
    ),
    FeatureGuideItem(
      title: 'حاسبة الزكاة الشرعية الشاملة 💰',
      category: 'الفقه والمعاملات',
      icon: Icons.calculate_rounded,
      steps:
          '1. ادخل إلى شاشة "حاسبة الزكاة" من القائمة الجانبية.\n2. اختر نوع الزكاة (زكاة المال والمدخرات، زكاة الذهب والفضة، عروض التجارة، أو زكاة الفطر).\n3. أدخل قيمة المدخرات أو وزن الذهب/الفضة بالجرام.\n4. سيتحقق التطبيق تلقائياً من بلوغ النصاب الشرعي (85 جرام عيار 24) وحساب الواجب إخراجه بنسبة 2.5%.',
      tip: 'يتم احتساب نصاب الذهب والفضة وفق الأسعار والضوابط الفقهية المعتمدة.',
    ),
    FeatureGuideItem(
      title: 'إذاعات القرآن الكريم المباشرة 📻',
      category: 'التلاوات والإذاعة',
      icon: Icons.radio_rounded,
      steps:
          '1. افتح شاشة "إذاعة القرآن الكريم" من التطبيق.\n2. اختر محطتك المفضلة (إذاعة القاهرة، إذاعة مكة المكرمة، إذاعة المدينة، أو إذاعات كبار القراء).\n3. استمع للبث الحي المباشر بنقاء صوتي فائق مع إمكانية التشغيل في الخلفية وأثناء استخدام الهاتف.',
      tip: 'المشغل الصوتي يدعم التحكم المباشر من شاشة القفل ومركز الإشعارات.',
    ),
    FeatureGuideItem(
      title: 'موسوعة أسماء الله الحسنى الـ 99 ﷻ',
      category: 'العقيدة والإيمان',
      icon: Icons.stars_rounded,
      steps:
          '1. اختر "أسماء الله الحسنى" من القائمة الرئيسية.\n2. استعرض أسماء الله الـ 99 بتصميم بطاقات إسلامية فاخرة.\n3. اضغط على أي اسم لعرض معناه اللغوي، دلالته الإيمانية، وروده في القرآن، وفضل الدعاء به.\n4. استخدم شريط البحث السريع للبحث عن أي اسم ومعناه.',
      tip: 'تساعدك الموسوعة على تدبر وحفظ أسماء الله الحسنى وفهم معانيها العميقة.',
    ),
    FeatureGuideItem(
      title: 'المسابقة الدينية والثقافية التفاعلية 🏆',
      category: 'المسابقات والمعرفة',
      icon: Icons.quiz_rounded,
      steps:
          '1. افتح شاشة "المسابقة الإسلامية" من القائمة الجانبية.\n2. اختر المستوى وبنك الأسئلة (القرآن، السيرة النبوية، الفقه، الصحابة).\n3. أجب عن الأسئلة التفاعلية واحصد النقاط والأوسمة الإيمانية مع تصحيح فوري للإجابات.',
      tip: 'تتضمن كل إجابة توثيقاً وشرحاً ميسراً للمعلومة الدينية لزيادة المعرفة.',
    ),
    FeatureGuideItem(
      title: 'مصمم وبطاقات التهاني والأدعية 🎨',
      category: 'المشاركة والتواصل',
      icon: Icons.card_giftcard_rounded,
      steps:
          '1. ادخل إلى "البطاقات الإسلامية" من القائمة.\n2. اختر المناسبة (رمضان، الأعياد، الجمعة، تهنئة بالقرآن، أدعية مأثورة).\n3. خصص الزخرفة والخط وخلفية البطاقة.\n4. اضغط "مشاركة" لإرسال البطاقة كصورة عالية الدقة عبر واتساب ومواقع التواصل.',
      tip: 'جميع البطاقات مصممة بزخارف إسلامية أصيلة وبدون أي علامات مائية مزعجة.',
    ),
    FeatureGuideItem(
      title: 'الأذكار المسموعة أوفلاين 100% لـ 4 قراء 🔊',
      category: 'الأذكار والسبحة',
      icon: Icons.volume_up_rounded,
      steps:
          '1. افتح أي قسم من أقسام الأذكار (الصباح، المساء، النوم، السفر، الاستخارة، إلخ).\n2. ستجد زر تشغيل صوتي مسموع وشارة القارئ أعلى كل كارت ذِكر.\n3. اضغط على شارة القارئ للاختيار بين (مشاري العفاسي، سعد الغامدي، إدريس أبكر، ماهر المعيقلي).\n4. استمع للذكر أثناء التسبيح بالعداد الدائري الملموم بالأسفل.',
      tip: 'تعمل جميع صوتيات الأذكار أوفلاين 100% بدون إنترنت مع ضغط فائق الحجم بنسبة 87%.',
    ),
    FeatureGuideItem(
      title: 'أزرار التكبير والتصغير الفوري لخط المصحف 🔍',
      category: 'القرآن الكريم',
      icon: Icons.zoom_in_rounded,
      steps:
          '1. افتح أي سورة من المصحف الشريف.\n2. ستجد زر (-) للتصغير وزر (+) للتكبير في الشريط العلوي على يمين ويسار اسم السورة مباشرة.\n3. اضغط للتكبير أو التصغير الفوري بحجم مريح ومناسب لعينيك.',
      tip: 'يتم حفظ حجم الخط المفضل محلياً على جهازك تلقائياً.',
    ),
    FeatureGuideItem(
      title: 'التنقل الصوتي السلس والتذكر التلقائي للآيات 📖',
      category: 'القرآن الكريم',
      icon: Icons.auto_stories_rounded,
      steps:
          '1. عند استماع التلاوة، ينتقل الصوت فورياً ومباشرة بين الآيات بدون توقف أو تأخير شبكي.\n2. يتم حفظ السورة والآية المباشرة التي توقفت عندها تلقائياً بمجرد التمرير أو الاستماع.\n3. عند فتح شاشة القرآن مجدداً، اضغط "متابعة القراءة" لتنتقل فوراً لأحدث آية وصلت إليها.',
      tip: 'يمكنك أيضاً استخدام زر "حفظ كعلامة وقوف" للعلامات اليدوية المرجعية.',
    ),
    FeatureGuideItem(
      title: 'عرض التفسير الميسر لأي آية أوفلاين 📖',
      category: 'القرآن الكريم',
      icon: Icons.menu_book_rounded,
      steps:
          '1. افتح المصحف الشريف واختر السورة.\n2. اضغط على أي آية كريمة.\n3. اختر "عرض التفسير الميسر" من القائمة.\n4. سيظهر التفسير فوراً ويتم حفظه محلياً ليعمل بدون إنترنت للأبد!',
      tip: 'يمكنك اختيار التفسير لأي آية من الـ 6236 آية في القرآن الكريم.',
    ),
    FeatureGuideItem(
      title: 'متابعة الورد اليومي وقضاء الفوائت 🕌',
      category: 'الورد والعبادات',
      icon: Icons.fact_check_rounded,
      steps:
          '1. اذهب لشاشة "الورد اليومي" من الشاشة الرئيسية.\n2. ستجد الصلوات الخمس، السنن، ورد القرآن، وأذكار الصباح والمساء.\n3. يمكنك الرجوع بالتقويم لأي يوم سابق لتسجيل وقضاء الصلوات الفائتة في تاريخها الصحيح دون التأثير على اليوم الحالي.',
      tip: 'يمكنك إضافة عبادات مخصصة جديدة عبر زر (+) الأسفل.',
    ),
    FeatureGuideItem(
      title: 'تحديد اتجاه القبلة بالواقع المعزز AR 🕌',
      category: 'القبلة والمواقيت',
      icon: Icons.explore_rounded,
      steps:
          '1. اختر "اتجاه القبلة" من الشاشة الرئيسية.\n2. فعّل الكاميرا وشعاع الواقع المعزز.\n3. حرك الهاتف حتى يظهر مجسم الكعبة المشرفة وتضيء مؤشرات الاتجاه باللون الأخضر.',
      tip: 'احرص على الابتعاد عن المعادن والمجالات المغناطيسية لدقة البوصلة.',
    ),
    FeatureGuideItem(
      title: 'المسبحة الـ 3D والعداد الرقمي 📿',
      category: 'الأذكار والسبحة',
      icon: Icons.auto_awesome_rounded,
      steps:
          '1. افتح شاشة "المسبحة 3D" من الشاشة الرئيسية.\n2. اسحب الخرزات أو انقر على الشاشة للتسبيح مع تفاعل لمسي وصوتي ممتاز.\n3. اختر نوع الذكر أو الاستغفار وسيقوم العداد بالتجميع التلقائي.',
      tip: 'يمكنك التحكم في تشغيل أو إيقاف الصوت والاهتزاز من أيقونات الشاشة علوياً.',
    ),
    FeatureGuideItem(
      title: 'تنظيم الختمات الجماعية والمشتركة 👥',
      category: 'القرآن الكريم',
      icon: Icons.groups_rounded,
      steps:
          '1. اذهب لشاشة "الختمات القرأنية".\n2. اضغط على "إنشاء ختمة جديدة" وحدد اسمها وأحزابها.\n3. شارك كود الختمة مع العائلة والأصدقاء ليختار كل مشارك جزءه المفضل وتتتابع نسبة الإنجاز.',
      tip: 'تمنحك الختمة الجماعية وسام "صاحب الختمة الجماعية 🏆".',
    ),
    FeatureGuideItem(
      title: 'متجر السمات والمقتنيات الإسلامية 🎨',
      category: 'التخصيص والمظهر',
      icon: Icons.palette_rounded,
      steps:
          '1. افتح "الإعدادات ⚙️" أو شاشة "المتجر الإسلامي".\n2. اختر مظهرك المفضل (الأخضر الزمردي 🌿، الأزرق الليلي 🌌، الذهبي الفاخر ✨، الرخام الأبيض الملكي 🏛️).\n3. يتغير مظهر التطبيق بالكامل فوراً ليتناسب مع ذوقك وراحتك البصرية.',
      tip: 'جميع السمات مجانية ومصممة بأعلى معايير التباين والراحة للعينين.',
    ),
    FeatureGuideItem(
      title: 'تقييم التطبيق ومشاركة الأجر على المتجر ⭐️',
      category: 'الإعدادات',
      icon: Icons.star_rounded,
      steps:
          '1. افتح "الإعدادات ⚙️" أو اضغط على كارت التقييم التفاعلي بالشاشة الرئيسية.\n2. اختر تقييم 5 نجوم وسيفتح لك متجر التطبيقات الرسمي مباشرة لكتابة رأيك الطيب.',
      tip: 'تقييمك وكلماتك المباركة تساهم في وصول التطبيق لآلاف المسلمين حول العالم.',
    ),
    FeatureGuideItem(
      title: 'استعراض المصادر والمراجع والتوثيق 📚',
      category: 'حول التطبيق',
      icon: Icons.verified_user_rounded,
      steps:
          '1. افتح "الإعدادات ⚙️".\n2. اضغط على كارت "المراجع والمصادر الرسمية 📚".\n3. ستجد توثيق كامل للأحاديث وأصالة الأذكار والمكتبات البرمجية المستخدمة وحماية التشفير الرقمي SHA-256.',
      tip: 'يمكنك أيضاً قراءة ملف REFERENCES.md في مجلد التطبيق.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    final filteredGuides = _allGuides.where((guide) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return guide.title.toLowerCase().contains(q) ||
          guide.steps.toLowerCase().contains(q) ||
          guide.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'دليل ميزات واستخدام التطبيق',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: Column(
          children: [
            // Search Header Bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.cairo(color: theme.textColor),
                decoration: InputDecoration(
                  hintText: 'ابحث عن طريقة أي ميزة (مثلاً: التفسير، القبلة، الهجري)...',
                  hintStyle: GoogleFonts.cairo(
                    color: theme.subtitleColor.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: theme.accentColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: theme.subtitleColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ),

            // Guides List
            Expanded(
              child: filteredGuides.isEmpty
                  ? Center(
                      child: Text(
                        'لم يتم العثور على ميزة بهذا الاسم، حاول البحث بكلمة أخرى',
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: filteredGuides.length,
                      itemBuilder: (context, index) {
                        final item = filteredGuides[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                              color: theme.accentColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: theme.accentColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: theme.accentColor,
                                size: 24.sp,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                            subtitle: Text(
                              'التصنيف: ${item.category}',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: theme.subtitleColor,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'خطوات الوصول والتشغيل:',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: theme.accentColor,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      item.steps,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        color: theme.textColor,
                                        height: 1.6,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: theme.accentColor.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline_rounded,
                                            color: theme.accentColor,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              item.tip,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12.sp,
                                                color: theme.subtitleColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
