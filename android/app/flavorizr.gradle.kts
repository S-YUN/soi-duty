import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("env")

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.nuyoes.soiduty.dev"
            resValue(type = "string", name = "app_name", value = "소이듀티 dev")
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.nuyoes.soiduty"
            resValue(type = "string", name = "app_name", value = "소이듀티")
        }
    }

    buildFeatures.resValues = true
}