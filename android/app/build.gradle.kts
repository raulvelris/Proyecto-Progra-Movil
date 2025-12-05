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
