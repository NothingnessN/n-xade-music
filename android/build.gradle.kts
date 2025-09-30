allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// JVM hedeflerini tüm alt projelerde hizala (plugin modülleri dahil)
subprojects {
<<<<<<< HEAD
    // Varsayılan: Kotlin JVM hedefi 11
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "11"
        }
    }
=======
    // Varsayılan: Kotlin JVM hedefi 17 (device_info_plus uyumluluğu için)
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
    
    // Java compatibility için
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_11.toString()
        targetCompatibility = JavaVersion.VERSION_11.toString()
    }
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)

    // Java 1.8 ile derlenen modüller: Kotlin'i de 1.8'e indir
    if (project.name in listOf("audiotags", "on_audio_query_android")) {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
<<<<<<< HEAD
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
=======
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_1_8.toString()
            targetCompatibility = JavaVersion.VERSION_1_8.toString()
        }
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)
    }

    // shared_preferences_android Java 11 ile derleniyor: Kotlin'i 11'e yükselt
    if (project.name == "shared_preferences_android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
<<<<<<< HEAD
            kotlinOptions {
                jvmTarget = "11"
            }
        }
=======
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_11.toString()
            targetCompatibility = JavaVersion.VERSION_11.toString()
        }
    }

    // device_info_plus Java 17 ile derleniyor: Kotlin'i 17'de tut
    if (project.name == "device_info_plus") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

