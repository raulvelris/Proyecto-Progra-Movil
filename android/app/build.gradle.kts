import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val dotenv = Properties().apply {
    val envFile = rootProject.file("../../.env")
    if (envFile.exists()) {
        load(FileInputStream(envFile))
        println("Archivo .env cargado correctamente desde: ${envFile.path}")
    } else {
        println("No se encontró el archivo .env en: ${envFile.path}")
    }
}

val googleMapsApiKey: String = dotenv.getProperty("GOOGLE_MAPS_API_KEY", "")

android {
    namespace = "com.example.eventmaster"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.eventmaster"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "google_maps_api_key", googleMapsApiKey)
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
