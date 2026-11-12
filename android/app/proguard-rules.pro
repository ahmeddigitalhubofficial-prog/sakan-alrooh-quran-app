# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Just Audio & Media
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_service.** { *; }

# Firebase & Google Play Services
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.play.core.** { *; }
-keep class de.cyberdeck.in_app_update.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.play.core.**

# Shorebird Code Push
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-dontwarn io.flutter.embedding.engine.FlutterJNI

# Huawei Mobile Services (HMS Core)
-keep class com.huawei.hms.** { *; }
-keep class com.huawei.agconnect.** { *; }
-dontwarn com.huawei.hms.**
-dontwarn com.huawei.agconnect.**

# HomeWidget & AppWidgetProvider
-keep class com.nooralhoda.official.app.NoorAlHodaWidgetProvider { *; }
-keepclassmembers class com.nooralhoda.official.app.NoorAlHodaWidgetProvider { *; }
-keep class com.nooralhoda.official.app.NoorAlHodaCompactWidgetProvider { *; }
-keepclassmembers class com.nooralhoda.official.app.NoorAlHodaCompactWidgetProvider { *; }
-keep class es.antonborri.home_widget.** { *; }

# General R8 / Proguard flags
-dontwarn **
-ignorewarnings
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
