# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Audio Service rules
-keep class com.ryanheise.audioservice.** { *; }

# Just Audio rules
-keep class com.ryanheise.just_audio.** { *; }

# On Audio Query rules
-keep class com.lucasjosino.on_audio_query.** { *; }

# Google Mobile Ads rules
-keep class com.google.android.gms.ads.** { *; }

# In App Purchase rules
-keep class com.android.billingclient.** { *; }

# Google Play Core rules
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep annotation classes
-keep @interface * {
    *;
}

# Keep classes with @Keep annotation
-keep class * {
    @androidx.annotation.Keep *;
}

# Keep classes with @Keep annotation (AndroidX)
-keep class * {
    @android.support.annotation.Keep *;
}
