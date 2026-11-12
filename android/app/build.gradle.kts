import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val agconnectConfigFile = file("agconnect-services.json")
if (agconnectConfigFile.exists()) {
    apply(plugin = "com.huawei.agconnect")
}


val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nooralhoda.official.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nooralhoda.official.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        release {
            val hasKeystore = keystorePropertiesFile.exists() &&
                              keystoreProperties["storeFile"]?.let { file(it).exists() } == true
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this
            var abiFilter: String? = null
            try {
                val filtersField = output.javaClass.getMethod("getFilters")
                val filtersList = filtersField.invoke(output) as Collection<*>
                for (filter in filtersList) {
                    val type = filter?.javaClass?.getMethod("getFilterType")?.invoke(filter) as? String
                    if (type == "ABI") {
                        abiFilter = filter.javaClass.getMethod("getIdentifier").invoke(filter) as? String
                        break
                    }
                }
            } catch (e: Exception) {
                // ignore
            }

            val nameSuffix = if (abiFilter != null) "-$abiFilter" else ""
            try {
                output.javaClass.getMethod("setOutputFileName", String::class.java)
                    .invoke(output, "sakan_al_rooh-v${variant.versionName}-${variant.name}$nameSuffix.apk")
            } catch (e: Exception) {
                // ignore
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")}
