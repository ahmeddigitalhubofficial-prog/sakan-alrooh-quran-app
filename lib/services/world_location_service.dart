import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class WorldCity {
  final String id;
  final String nameAr;
  final String nameEn;
  final String countryAr;
  final String countryEn;
  final String flag;
  final double lat;
  final double lng;
  final String calculationMethod;

  const WorldCity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.countryAr,
    required this.countryEn,
    required this.flag,
    required this.lat,
    required this.lng,
    this.calculationMethod = 'egyptian',
  });

  String get fullDisplayName => '$nameAr، $countryAr $flag';

  Coordinates toCoordinates() => Coordinates(lat, lng);
}

/// خدمة المواقع العالمية الفلكية الموحدة لتطبيق سكن الروح
class WorldLocationService {
  static const String keyCity = 'saved_city';
  static const String keyCountry = 'saved_country';
  static const String keyLat = 'saved_lat';
  static const String keyLng = 'saved_lng';
  static const String keyUseGps = 'use_gps';
  static const String keyMethod = 'calculation_method';

  /// قاعدة البيانات العالمية الشاملة للمدن والمحافظات (مصر والعالم الإسلامي والعواصم الكبرى)
  static final List<WorldCity> allCities = [
    // ==================== 1. جمهورية مصر العربية (كافة المحافظات الـ 27) ====================
    const WorldCity(id: 'cairo', nameAr: 'القاهرة', nameEn: 'Cairo', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.0444, lng: 31.2357, calculationMethod: 'egyptian'),
    const WorldCity(id: 'alexandria', nameAr: 'الإسكندرية', nameEn: 'Alexandria', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.2001, lng: 29.9187, calculationMethod: 'egyptian'),
    const WorldCity(id: 'giza', nameAr: 'الجيزة', nameEn: 'Giza', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.0131, lng: 31.2089, calculationMethod: 'egyptian'),
    const WorldCity(id: 'port_said', nameAr: 'بورسعيد', nameEn: 'Port Said', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.2653, lng: 32.3019, calculationMethod: 'egyptian'),
    const WorldCity(id: 'suez', nameAr: 'السويس', nameEn: 'Suez', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 29.9668, lng: 32.5498, calculationMethod: 'egyptian'),
    const WorldCity(id: 'ismailia', nameAr: 'الإسماعيلية', nameEn: 'Ismailia', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.5965, lng: 32.2715, calculationMethod: 'egyptian'),
    const WorldCity(id: 'mansoura', nameAr: 'المنصورة (الدقهلية)', nameEn: 'Mansoura', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.0409, lng: 31.3785, calculationMethod: 'egyptian'),
    const WorldCity(id: 'tanta', nameAr: 'طنطا (الغربية)', nameEn: 'Tanta', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.7865, lng: 31.0004, calculationMethod: 'egyptian'),
    const WorldCity(id: 'zagazig', nameAr: 'الزقازيق (الشرقية)', nameEn: 'Zagazig', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.5765, lng: 31.5041, calculationMethod: 'egyptian'),
    const WorldCity(id: 'banha', nameAr: 'بنها (القليوبية)', nameEn: 'Banha', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.4660, lng: 31.1853, calculationMethod: 'egyptian'),
    const WorldCity(id: 'shibin', nameAr: 'شبين الكوم (المنوفية)', nameEn: 'Shibin El Kom', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 30.5526, lng: 31.0090, calculationMethod: 'egyptian'),
    const WorldCity(id: 'damanhur', nameAr: 'دمنهور (البحيرة)', nameEn: 'Damanhur', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.0409, lng: 30.4700, calculationMethod: 'egyptian'),
    const WorldCity(id: 'kafr_el_sheikh', nameAr: 'كفر الشيخ', nameEn: 'Kafr El Sheikh', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.1107, lng: 30.9388, calculationMethod: 'egyptian'),
    const WorldCity(id: 'damietta', nameAr: 'دمياط', nameEn: 'Damietta', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.4175, lng: 31.8144, calculationMethod: 'egyptian'),
    const WorldCity(id: 'faiyum', nameAr: 'الفيوم', nameEn: 'Faiyum', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 29.3084, lng: 30.8428, calculationMethod: 'egyptian'),
    const WorldCity(id: 'beni_suef', nameAr: 'بني سويف', nameEn: 'Beni Suef', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 29.0661, lng: 31.0994, calculationMethod: 'egyptian'),
    const WorldCity(id: 'minya', nameAr: 'المنيا', nameEn: 'Minya', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 28.0871, lng: 30.7618, calculationMethod: 'egyptian'),
    const WorldCity(id: 'asyut', nameAr: 'أسيوط', nameEn: 'Asyut', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 27.1783, lng: 31.1859, calculationMethod: 'egyptian'),
    const WorldCity(id: 'sohag', nameAr: 'سوهاج', nameEn: 'Sohag', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 26.5590, lng: 31.6957, calculationMethod: 'egyptian'),
    const WorldCity(id: 'qena', nameAr: 'قنا', nameEn: 'Qena', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 26.1551, lng: 32.7160, calculationMethod: 'egyptian'),
    const WorldCity(id: 'luxor', nameAr: 'الأقصر', nameEn: 'Luxor', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 25.6872, lng: 32.6396, calculationMethod: 'egyptian'),
    const WorldCity(id: 'aswan', nameAr: 'أسوان', nameEn: 'Aswan', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 24.0889, lng: 32.8998, calculationMethod: 'egyptian'),
    const WorldCity(id: 'hurghada', nameAr: 'الغردقة (البحر الأحمر)', nameEn: 'Hurghada', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 27.2579, lng: 33.8116, calculationMethod: 'egyptian'),
    const WorldCity(id: 'sharm', nameAr: 'شرم الشيخ (جنوب سيناء)', nameEn: 'Sharm El Sheikh', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 27.9158, lng: 34.3299, calculationMethod: 'egyptian'),
    const WorldCity(id: 'arish', nameAr: 'العريش (شمال سيناء)', nameEn: 'Arish', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.1316, lng: 33.7984, calculationMethod: 'egyptian'),
    const WorldCity(id: 'matrouh', nameAr: 'مرسى مطروح', nameEn: 'Marsa Matruh', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 31.3543, lng: 27.2373, calculationMethod: 'egyptian'),
    const WorldCity(id: 'kharga', nameAr: 'الخارجة (الوادي الجديد)', nameEn: 'Kharga', countryAr: 'مصر', countryEn: 'Egypt', flag: '🇪🇬', lat: 25.4514, lng: 30.5470, calculationMethod: 'egyptian'),

    // ==================== 2. المملكة العربية السعودية (طريقة أم القرى) ====================
    const WorldCity(id: 'makkah', nameAr: 'مكة المكرمة 🕋', nameEn: 'Makkah', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 21.4225, lng: 39.8262, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'madinah', nameAr: 'المدينة المنورة 🕌', nameEn: 'Madinah', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 24.4672, lng: 39.6111, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'riyadh', nameAr: 'الرياض', nameEn: 'Riyadh', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 24.7136, lng: 46.6753, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'jeddah', nameAr: 'جدة', nameEn: 'Jeddah', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 21.5433, lng: 39.1728, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'dammam', nameAr: 'الدمام والخبر', nameEn: 'Dammam', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 26.4207, lng: 50.0888, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'taif', nameAr: 'الطائف', nameEn: 'Taif', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 21.2854, lng: 40.4222, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'tabuk', nameAr: 'تبوك', nameEn: 'Tabuk', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 28.3835, lng: 36.5662, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'buraidah', nameAr: 'بريدة (القصيم)', nameEn: 'Buraidah', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 26.3592, lng: 43.9818, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'abha', nameAr: 'أبها وعسير', nameEn: 'Abha', countryAr: 'السعودية', countryEn: 'Saudi Arabia', flag: '🇸🇦', lat: 18.2164, lng: 42.5053, calculationMethod: 'umm_al_qura'),

    // ==================== 3. دول الخليج العربي ====================
    const WorldCity(id: 'dubai', nameAr: 'دبي', nameEn: 'Dubai', countryAr: 'الإمارات', countryEn: 'UAE', flag: '🇦🇪', lat: 25.2048, lng: 55.2708, calculationMethod: 'dubai'),
    const WorldCity(id: 'abu_dhabi', nameAr: 'أبوظبي', nameEn: 'Abu Dhabi', countryAr: 'الإمارات', countryEn: 'UAE', flag: '🇦🇪', lat: 24.4539, lng: 54.3773, calculationMethod: 'dubai'),
    const WorldCity(id: 'sharjah', nameAr: 'الشارقة', nameEn: 'Sharjah', countryAr: 'الإمارات', countryEn: 'UAE', flag: '🇦🇪', lat: 25.3463, lng: 55.4209, calculationMethod: 'dubai'),
    const WorldCity(id: 'kuwait_city', nameAr: 'مدينة الكويت', nameEn: 'Kuwait City', countryAr: 'الكويت', countryEn: 'Kuwait', flag: '🇰🇼', lat: 29.3759, lng: 47.9774, calculationMethod: 'kuwait'),
    const WorldCity(id: 'doha', nameAr: 'الدوحة', nameEn: 'Doha', countryAr: 'قطر', countryEn: 'Qatar', flag: '🇶🇦', lat: 25.2854, lng: 51.5310, calculationMethod: 'qatar'),
    const WorldCity(id: 'manama', nameAr: 'المنامة', nameEn: 'Manama', countryAr: 'البحرين', countryEn: 'Bahrain', flag: '🇧🇭', lat: 26.2285, lng: 50.5860, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'muscat', nameAr: 'مسقط', nameEn: 'Muscat', countryAr: 'عُمان', countryEn: 'Oman', flag: '🇴🇲', lat: 23.5880, lng: 58.3829, calculationMethod: 'umm_al_qura'),

    // ==================== 4. بلاد الشام وفلسطين والعراق ====================
    const WorldCity(id: 'jerusalem', nameAr: 'القدس الشريف 🇵🇸', nameEn: 'Jerusalem', countryAr: 'فلسطين', countryEn: 'Palestine', flag: '🇵🇸', lat: 31.7683, lng: 35.2137, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'gaza', nameAr: 'غزة العزة 🇵🇸', nameEn: 'Gaza', countryAr: 'فلسطين', countryEn: 'Palestine', flag: '🇵🇸', lat: 31.5017, lng: 34.4668, calculationMethod: 'egyptian'),
    const WorldCity(id: 'amman', nameAr: 'عمّان', nameEn: 'Amman', countryAr: 'الأردن', countryEn: 'Jordan', flag: '🇯🇴', lat: 31.9454, lng: 35.9284, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'baghdad', nameAr: 'بغداد', nameEn: 'Baghdad', countryAr: 'العراق', countryEn: 'Iraq', flag: '🇮🇶', lat: 33.3152, lng: 44.3661, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'basra', nameAr: 'البصرة', nameEn: 'Basra', countryAr: 'العراق', countryEn: 'Iraq', flag: '🇮🇶', lat: 30.5085, lng: 47.7804, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'erbil', nameAr: 'أربيل', nameEn: 'Erbil', countryAr: 'العراق', countryEn: 'Iraq', flag: '🇮🇶', lat: 36.1901, lng: 44.0091, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'damascus', nameAr: 'دمشق', nameEn: 'Damascus', countryAr: 'سوريا', countryEn: 'Syria', flag: '🇸🇾', lat: 33.5138, lng: 36.2765, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'aleppo', nameAr: 'حلب', nameEn: 'Aleppo', countryAr: 'سوريا', countryEn: 'Syria', flag: '🇸🇾', lat: 36.2021, lng: 37.1343, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'beirut', nameAr: 'بيروت', nameEn: 'Beirut', countryAr: 'لبنان', countryEn: 'Lebanon', flag: '🇱🇧', lat: 33.8938, lng: 35.5018, calculationMethod: 'muslim_world_league'),

    // ==================== 5. شمال أفريقيا والسودان واليمن ====================
    const WorldCity(id: 'khartoum', nameAr: 'الخرطوم', nameEn: 'Khartoum', countryAr: 'السودان', countryEn: 'Sudan', flag: '🇸🇩', lat: 15.5007, lng: 32.5599, calculationMethod: 'egyptian'),
    const WorldCity(id: 'sanaa', nameAr: 'صنعاء', nameEn: 'Sanaa', countryAr: 'اليمن', countryEn: 'Yemen', flag: '🇾🇪', lat: 15.3694, lng: 44.1910, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'aden', nameAr: 'عدن', nameEn: 'Aden', countryAr: 'اليمن', countryEn: 'Yemen', flag: '🇾🇪', lat: 12.7794, lng: 45.0367, calculationMethod: 'umm_al_qura'),
    const WorldCity(id: 'tripoli', nameAr: 'طرابلس', nameEn: 'Tripoli', countryAr: 'ليبيا', countryEn: 'Libya', flag: '🇱🇾', lat: 32.8872, lng: 13.1913, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'benghazi', nameAr: 'بنغازي', nameEn: 'Benghazi', countryAr: 'ليبيا', countryEn: 'Libya', flag: '🇱🇾', lat: 32.1167, lng: 20.0667, calculationMethod: 'egyptian'),
    const WorldCity(id: 'tunis', nameAr: 'تونس العاصمة', nameEn: 'Tunis', countryAr: 'تونس', countryEn: 'Tunisia', flag: '🇹🇳', lat: 36.8065, lng: 10.1815, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'algiers', nameAr: 'الجزائر العاصمة', nameEn: 'Algiers', countryAr: 'الجزائر', countryEn: 'Algeria', flag: '🇩🇿', lat: 36.7538, lng: 3.0588, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'oran', nameAr: 'وهران', nameEn: 'Oran', countryAr: 'الجزائر', countryEn: 'Algeria', flag: '🇩🇿', lat: 35.6987, lng: -0.6349, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'casablanca', nameAr: 'الدار البيضاء', nameEn: 'Casablanca', countryAr: 'المغرب', countryEn: 'Morocco', flag: '🇲🇦', lat: 33.5731, lng: -7.5898, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'rabat', nameAr: 'الرباط', nameEn: 'Rabat', countryAr: 'المغرب', countryEn: 'Morocco', flag: '🇲🇦', lat: 34.0209, lng: -6.8416, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'marrakech', nameAr: 'مراكش', nameEn: 'Marrakech', countryAr: 'المغرب', countryEn: 'Morocco', flag: '🇲🇦', lat: 31.6295, lng: -7.9811, calculationMethod: 'muslim_world_league'),

    // ==================== 6. تركيا والعالم الإسلامي ====================
    const WorldCity(id: 'istanbul', nameAr: 'إسطنبول', nameEn: 'Istanbul', countryAr: 'تركيا', countryEn: 'Turkey', flag: '🇹🇷', lat: 41.0082, lng: 28.9784, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'ankara', nameAr: 'أنقرة', nameEn: 'Ankara', countryAr: 'تركيا', countryEn: 'Turkey', flag: '🇹🇷', lat: 39.9334, lng: 32.8597, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'kuala_lumpur', nameAr: 'كوالالمبور', nameEn: 'Kuala Lumpur', countryAr: 'ماليزيا', countryEn: 'Malaysia', flag: '🇲🇾', lat: 3.1390, lng: 101.6869, calculationMethod: 'singapore'),
    const WorldCity(id: 'jakarta', nameAr: 'جاكرتا', nameEn: 'Jakarta', countryAr: 'إندونيسيا', countryEn: 'Indonesia', flag: '🇮🇩', lat: -6.2088, lng: 106.8456, calculationMethod: 'singapore'),
    const WorldCity(id: 'islamabad', nameAr: 'إسلام آباد', nameEn: 'Islamabad', countryAr: 'باكستان', countryEn: 'Pakistan', flag: '🇵🇰', lat: 33.6844, lng: 73.0479, calculationMethod: 'karachi'),
    const WorldCity(id: 'karachi_city', nameAr: 'كراتشي', nameEn: 'Karachi', countryAr: 'باكستان', countryEn: 'Pakistan', flag: '🇵🇰', lat: 24.8607, lng: 67.0011, calculationMethod: 'karachi'),

    // ==================== 7. أوروبا والمهجر ====================
    const WorldCity(id: 'london', nameAr: 'لندن', nameEn: 'London', countryAr: 'المملكة المتحدة', countryEn: 'United Kingdom', flag: '🇬🇧', lat: 51.5074, lng: -0.1278, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'manchester', nameAr: 'مانشستر', nameEn: 'Manchester', countryAr: 'المملكة المتحدة', countryEn: 'United Kingdom', flag: '🇬🇧', lat: 53.4808, lng: -2.2426, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'paris', nameAr: 'باريس', nameEn: 'Paris', countryAr: 'فرنسا', countryEn: 'France', flag: '🇫🇷', lat: 48.8566, lng: 2.3522, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'berlin', nameAr: 'برلين', nameEn: 'Berlin', countryAr: 'ألمانيا', countryEn: 'Germany', flag: '🇩🇪', lat: 52.5200, lng: 13.4050, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'frankfurt', nameAr: 'فرانكفورت', nameEn: 'Frankfurt', countryAr: 'ألمانيا', countryEn: 'Germany', flag: '🇩🇪', lat: 50.1109, lng: 8.6821, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'amsterdam', nameAr: 'أمستردام', nameEn: 'Amsterdam', countryAr: 'هولندا', countryEn: 'Netherlands', flag: '🇳🇱', lat: 52.3676, lng: 4.9041, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'brussels', nameAr: 'بروكسل', nameEn: 'Brussels', countryAr: 'بلجيكا', countryEn: 'Belgium', flag: '🇧🇪', lat: 50.8503, lng: 4.3517, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'rome', nameAr: 'روما', nameEn: 'Rome', countryAr: 'إيطاليا', countryEn: 'Italy', flag: '🇮🇹', lat: 41.9028, lng: 12.4964, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'milan', nameAr: 'ميلانو', nameEn: 'Milan', countryAr: 'إيطاليا', countryEn: 'Italy', flag: '🇮🇹', lat: 45.4642, lng: 9.1900, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'madrid', nameAr: 'مدريد', nameEn: 'Madrid', countryAr: 'إسبانيا', countryEn: 'Spain', flag: '🇪🇸', lat: 40.4168, lng: -3.7038, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'vienna', nameAr: 'فيينا', nameEn: 'Vienna', countryAr: 'النمسا', countryEn: 'Austria', flag: '🇦🇹', lat: 48.2082, lng: 16.3738, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'stockholm', nameAr: 'ستوكهولم', nameEn: 'Stockholm', countryAr: 'السويد', countryEn: 'Sweden', flag: '🇸🇪', lat: 59.3293, lng: 18.0686, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'moscow', nameAr: 'موسكو', nameEn: 'Moscow', countryAr: 'روسيا', countryEn: 'Russia', flag: '🇷🇺', lat: 55.7558, lng: 37.6173, calculationMethod: 'muslim_world_league'),

    // ==================== 8. أمريكا الشمالية وأستراليا ====================
    const WorldCity(id: 'new_york', nameAr: 'نيويورك', nameEn: 'New York', countryAr: 'أمريكا', countryEn: 'USA', flag: '🇺🇸', lat: 40.7128, lng: -74.0060, calculationMethod: 'north_america'),
    const WorldCity(id: 'washington', nameAr: 'واشنطن', nameEn: 'Washington', countryAr: 'أمريكا', countryEn: 'USA', flag: '🇺🇸', lat: 38.9072, lng: -77.0369, calculationMethod: 'north_america'),
    const WorldCity(id: 'chicago', nameAr: 'شيكاغو', nameEn: 'Chicago', countryAr: 'أمريكا', countryEn: 'USA', flag: '🇺🇸', lat: 41.8781, lng: -87.6298, calculationMethod: 'north_america'),
    const WorldCity(id: 'los_angeles', nameAr: 'لوس أنجلوس', nameEn: 'Los Angeles', countryAr: 'أمريكا', countryEn: 'USA', flag: '🇺🇸', lat: 34.0522, lng: -118.2437, calculationMethod: 'north_america'),
    const WorldCity(id: 'houston', nameAr: 'هيوستن (تكساس)', nameEn: 'Houston', countryAr: 'أمريكا', countryEn: 'USA', flag: '🇺🇸', lat: 29.7604, lng: -95.3698, calculationMethod: 'north_america'),
    const WorldCity(id: 'toronto', nameAr: 'تورونتو', nameEn: 'Toronto', countryAr: 'كندا', countryEn: 'Canada', flag: '🇨🇦', lat: 43.6532, lng: -79.3832, calculationMethod: 'north_america'),
    const WorldCity(id: 'montreal', nameAr: 'مونتريال', nameEn: 'Montreal', countryAr: 'كندا', countryEn: 'Canada', flag: '🇨🇦', lat: 45.5017, lng: -73.5673, calculationMethod: 'north_america'),
    const WorldCity(id: 'sydney', nameAr: 'سيدني', nameEn: 'Sydney', countryAr: 'أستراليا', countryEn: 'Australia', flag: '🇦🇺', lat: -33.8688, lng: 151.2093, calculationMethod: 'muslim_world_league'),
    const WorldCity(id: 'melbourne', nameAr: 'ملبورن', nameEn: 'Melbourne', countryAr: 'أستراليا', countryEn: 'Australia', flag: '🇦🇺', lat: -37.8136, lng: 144.9631, calculationMethod: 'muslim_world_league'),
  ];

  /// البحث السريع في المدن والدول (عربي وإنجليزي)
  static List<WorldCity> searchCities(String query) {
    if (query.trim().isEmpty) return allCities;
    final q = query.trim().toLowerCase();
    return allCities.where((c) {
      return c.nameAr.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.countryAr.toLowerCase().contains(q) ||
          c.countryEn.toLowerCase().contains(q);
    }).toList();
  }

  /// إيجاد المدينة بناءً على الاسم أو المعرف
  static WorldCity? findCity(String nameOrId) {
    for (final c in allCities) {
      if (c.id == nameOrId || c.nameAr == nameOrId || c.nameEn.toLowerCase() == nameOrId.toLowerCase()) {
        return c;
      }
    }
    return null;
  }

  /// الحصول على معلمات طريقة الحساب الفلكي المعتمدة
  static CalculationParameters getCalculationParameters(String methodName) {
    CalculationParameters params;
    switch (methodName) {
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'north_america':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'muslim_world_league':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'egyptian':
      default:
        params = CalculationMethod.egyptian.getParameters();
        break;
    }
    params.madhab = Madhab.shafi;
    return params;
  }

  /// استرجاع الإحداثيات النشطة المحفوظة للمستخدم
  static Future<Coordinates> getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final useGps = prefs.getBool(keyUseGps) ?? false;

    if (useGps) {
      final lat = prefs.getDouble(keyLat);
      final lng = prefs.getDouble(keyLng);
      if (lat != null && lng != null) {
        return Coordinates(lat, lng);
      }
    }

    final cityName = prefs.getString(keyCity) ?? 'القاهرة';
    final city = findCity(cityName);
    if (city != null) {
      return Coordinates(city.lat, city.lng);
    }

    final lat = prefs.getDouble(keyLat);
    final lng = prefs.getDouble(keyLng);
    if (lat != null && lng != null) {
      return Coordinates(lat, lng);
    }

    // القاهرة كخيار افتراضي أخير
    return Coordinates(30.0444, 31.2357);
  }

  /// استرجاع اسم المكان الكامل لعرضه للمستخدم (المدينة والدولة مع العلم)
  static Future<String> getCurrentLocationDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final cityName = prefs.getString(keyCity) ?? 'القاهرة';
    final countryName = prefs.getString(keyCountry);

    final city = findCity(cityName);
    if (city != null) {
      return city.fullDisplayName;
    }

    if (countryName != null && countryName.isNotEmpty) {
      return '$cityName، $countryName';
    }
    return cityName;
  }

  /// حفظ المدينة والدولة المختارة يدوياً
  static Future<void> saveManualCity(WorldCity city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCity, city.nameAr);
    await prefs.setString(keyCountry, city.countryAr);
    await prefs.setDouble(keyLat, city.lat);
    await prefs.setDouble(keyLng, city.lng);
    await prefs.setBool(keyUseGps, false);
    await prefs.setString(keyMethod, city.calculationMethod);
  }

  /// التحديد التلقائي الهجين الذكي (GPS + IP Fallback إذا فشل الـ GPS أو كان في مكان مغلق)
  static Future<Map<String, dynamic>> detectLocationSmart() async {
    // 1. محاولة استخدام الـ GPS أولاً
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );

          // مطابقة الإحداثيات مع أقرب مدينة في قاعدتنا لحفظ اسمها الفعلي
          final nearest = findNearestCity(position.latitude, position.longitude);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble(keyLat, position.latitude);
          await prefs.setDouble(keyLng, position.longitude);
          await prefs.setBool(keyUseGps, true);
          if (nearest != null) {
            await prefs.setString(keyCity, nearest.nameAr);
            await prefs.setString(keyCountry, nearest.countryAr);
            await prefs.setString(keyMethod, nearest.calculationMethod);
            return {
              'success': true,
              'source': 'gps',
              'city': nearest.nameAr,
              'country': nearest.countryAr,
              'display': nearest.fullDisplayName,
              'lat': position.latitude,
              'lng': position.longitude,
            };
          }
          return {
            'success': true,
            'source': 'gps',
            'city': 'موقعي الحالي',
            'country': '',
            'display': 'موقعي الحالي (GPS) 🛰️',
            'lat': position.latitude,
            'lng': position.longitude,
          };
        }
      }
    } catch (e) {
      debugPrint('GPS detection skipped or timed out: $e');
    }

    // 2. البديل الذكي الفوري: تحديد الموقع عبر مزود الإنترنت (IP Geolocation)
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('http://ip-api.com/json'));
      final response = await request.close().timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body);
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          final cityEn = data['city'] ?? '';
          final countryEn = data['country'] ?? '';

          final nearest = findNearestCity(lat, lon);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble(keyLat, lat);
          await prefs.setDouble(keyLng, lon);
          await prefs.setBool(keyUseGps, true);

          if (nearest != null) {
            await prefs.setString(keyCity, nearest.nameAr);
            await prefs.setString(keyCountry, nearest.countryAr);
            await prefs.setString(keyMethod, nearest.calculationMethod);
            return {
              'success': true,
              'source': 'network',
              'city': nearest.nameAr,
              'country': nearest.countryAr,
              'display': nearest.fullDisplayName,
              'lat': lat,
              'lng': lon,
            };
          } else {
            await prefs.setString(keyCity, cityEn);
            await prefs.setString(keyCountry, countryEn);
            return {
              'success': true,
              'source': 'network',
              'city': cityEn,
              'country': countryEn,
              'display': '$cityEn ($countryEn) 🌐',
              'lat': lat,
              'lng': lon,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('IP detection fallback error: $e');
    }

    return {'success': false, 'error': 'لم نتمكن من تحديد الموقع تلقائياً'};
  }

  /// إيجاد أقرب مدينة بناءً على الإحداثيات الجغرافية (Euclidean Haversine approximation)
  static WorldCity? findNearestCity(double lat, double lng) {
    WorldCity? nearest;
    double minDistance = double.infinity;

    for (final city in allCities) {
      final dLat = city.lat - lat;
      final dLng = city.lng - lng;
      final dist = (dLat * dLat) + (dLng * dLng);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = city;
      }
    }
    return nearest;
  }
}
