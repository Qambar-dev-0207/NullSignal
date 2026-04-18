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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            
            // Force compileSdkVersion to at least 34 to ensure lStar attribute is recognized
            android.compileSdkVersion(34)
            
            // Fix for namespace and compileOptions references in Kotlin DSL
            if (android.namespace == null) {
                android.namespace = "com.nullsignal.${project.name.replace(":", ".").replace("-", ".")}"
            }
            
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }

            // Force consistent androidx.core version
            project.configurations.all {
                resolutionStrategy.eachDependency {
                    if (requested.group == "androidx.core" && requested.name == "core") {
                        useVersion("1.9.0")
                    }
                    if (requested.group == "androidx.core" && requested.name == "core-ktx") {
                        useVersion("1.9.0")
                    }
                }
            }

            // Fix for AGP 8.0+ where 'package' attribute in AndroidManifest.xml is forbidden
            android.sourceSets.getByName("main").manifest.srcFile("src/main/AndroidManifest.xml")
            
            project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
                doFirst {
                    val manifestFile = mainManifest.get().asFile
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        if (content.contains("package=")) {
                            val newContent = content.replace(Regex("package=\"[^\"]*\""), "")
                            manifestFile.writeText(newContent)
                        }
                    }
                }
            }
        }
        
        project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        
        project.tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
