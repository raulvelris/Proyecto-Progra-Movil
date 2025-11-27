import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ PLUGIN DE FIREBASE (OBLIGATORIO)
    id("com.google.gms.google-services")

    // Flutter
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
    namespace = "com.eventmaster.app"
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
        applicationId = "com.eventmaster.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "google_maps_api_key", googleMapsApiKey)
    }
}


flutter {
    source = "../.."
}

dependencies {

    // ✅ BOLETÍN DE VERSIONES FIREBASE
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // ✅ AUTENTICACIÓN (LOGIN GOOGLE + EMAIL)
    implementation("com.google.firebase:firebase-auth")

    // ✅ ANALYTICS (opcional, recomendado)
    implementation("com.google.firebase:firebase-analytics")
}
