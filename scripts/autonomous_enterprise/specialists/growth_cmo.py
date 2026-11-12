# -*- coding: utf-8 -*-
"""
رئيس قطاع النمو والتسويق الفيروسي (Chief Marketing & Growth Officer - CMGO)
خبرة تفوق 20 عاماً في هندسة النمو الفيروسي (Growth Hacking) وسيكولوجية المستهلك في العالم العربي والإسلامي.
"""

import random

class GrowthCMO:
    def __init__(self):
        self.name = "د. كريم سامي (Chief Growth Officer)"
        self.experience = "22 عاماً في هندسة النمو وتطوير المنصات المليونية"

    def get_campaign_strategies(self):
        """توليد استراتيجيات وزوايا نفسية قوية للحملات التسويقية"""
        campaigns = [
            {
                "id": "moods_solace",
                "title": "حملة رفيق المشاعر: الملاذ الإيماني في لحظات الضيق",
                "core_hook": "لما تضيق بيك الدنيا ومتعرفش تشكي لمين.. في مكان في جيبك بيكلم قلبك بآيات تطمنك 🕊️",
                "target_feature": "رفيق المشاعر والسكينة (Spiritual Moods)",
                "target_audience": "الشباب، من يعانون من ضغوط الحياة، والباحثون عن سكينة نفسية",
                "hashtags": ["#سكن_الروح", "#راحة_نفسية", "#طمأنينة", "#قرآن", "#تطبيقات_إسلامية", "#فضفضة"],
                "call_to_action": "التطبيق متاح مجاناً لوجه الله بالكامل بدون أي إعلانات مزعجة."
            },
            {
                "id": "jannah_palace",
                "title": "حملة قصر الجنة: بناء بيتك في الجنة خطوة بخطوة",
                "core_hook": "تخيل تبني قصرك في الجنة غرفة بغرفة وشجرة بشجرة من خلال 12 ركعة يومياً! 🏰",
                "target_feature": "متتبع السنن وبناء قصر الجنة (12 ركعة)",
                "target_audience": "المصلون، الحريصون على السنن، الشباب والعائلات",
                "hashtags": ["#قصر_الجنة", "#سنن_الرواتب", "#سكن_الروح", "#الصلاة", "#الجنة", "#إيمانيات"],
                "call_to_action": "حمّل سكن الروح وابدأ بناء قصرك اليوم."
            },
            {
                "id": "khatma_web",
                "title": "حملة الختمة التشاركية العائلية برابط واحد",
                "core_hook": "أسهل طريقة لعمل ختمة قرآنية بين العيلة والأصدقاء برابط واحد في الواتساب دون الحاجة لتنزيل أي تطبيق 👨‍👩‍👧‍👦",
                "target_feature": "الختمة التشاركية برابط الويب المستقل",
                "target_audience": "العائلات، المجموعات الدينية، وزملاء العمل",
                "hashtags": ["#ختمة_قرآنية", "#سكن_الروح", "#القرآن_الكريم", "#صدقة_جارية", "#عائلتي"],
                "call_to_action": "شارك رابط الختمة في جروب العيلة وابدأوا معاً."
            },
            {
                "id": "no_ads_advantage",
                "title": "حملة التطبيق النقي: وداعاً للإعلانات المزعجة في صلاتك وقرآنك",
                "core_hook": "ليه تتشتت بإعلانات منبثقة وسط صلاتك وقراءتك للقرآن؟ سكن الروح صُمم ليكون نقياً لوجه الله 100% 🌙",
                "target_feature": "تطبيق مجاني بالكامل وخالٍ من الإعلانات المشتتة ويعمل أوفلاين",
                "target_audience": "كل مسلم يبحث عن الخشوع وتجربة هادئة وفاخرة",
                "hashtags": ["#سكن_الروح", "#بدون_إعلانات", "#المصحف_الشريف", "#أذكار_أوفلاين", "#تطبيق_إسلامي"],
                "call_to_action": "تنزيل مجاني مباشر وآمن عبر المتجر."
            }
        ]
        return campaigns

    def generate_ad_copy(self, campaign_id=None):
        """توليد نصوص إعلانية فيروسية عالية التحويل للنشر المباشر"""
        campaigns = self.get_campaign_strategies()
        selected = next((c for c in campaigns if c["id"] == campaign_id), random.choice(campaigns))
        
        copy = (
            f"✨ {selected['title']}\n\n"
            f"{selected['core_hook']}\n\n"
            f"🌿 {selected['target_feature']}\n"
            f"✨ {selected['call_to_action']}\n\n"
            f"📲 روابط التنزيل المباشرة والمجانية:\n"
            f"🤖 Google Play: https://play.google.com/store/apps/details?id=com.nooralhoda.official.app\n"
            f"🌸 Huawei AppGallery: https://appgallery.huawei.com/app/C118816285\n\n"
            f"{' '.join(selected['hashtags'])}"
        )
        return {
            "campaign": selected,
            "text": copy
        }
