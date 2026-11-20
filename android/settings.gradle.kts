pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    val flutterGradleDir =
        run {
            val sourceDir = file("$flutterSdkPath/packages/flutter_tools/gradle")
            if (sourceDir.canWrite()) {
                sourceDir
            } else {
                // NixOS / read-only SDK store: Gradle 9 requires included build directories to be writable.
                val writableDir = file("../build/flutter_tools_gradle")
                val marker = writableDir.resolve(".source_sdk_path")
                val expectedMarker = "${sourceDir.absolutePath}:v2"
                if (!marker.exists() || marker.readText() != expectedMarker) {
                    writableDir.deleteRecursively()
                    sourceDir.copyRecursively(writableDir, overwrite = true)
                    writableDir.walkTopDown().forEach { it.setWritable(true) }
                    // Remove Nixpkgs's Gradle-8 shim so Gradle 9 uses Flutter's settings.gradle.kts directly.
                    writableDir.resolve("settings.gradle").delete()
                    marker.writeText(expectedMarker)
                }
                writableDir
            }
        }

    includeBuild(flutterGradleDir.absolutePath)

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
