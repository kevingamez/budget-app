# Supabase + ktor + kotlinx-serialization rely on reflection metadata.
-keepattributes *Annotation*, InnerClasses
-keep,allowobfuscation,allowshrinking class kotlin.Metadata
-keep,allowobfuscation,allowshrinking class kotlinx.serialization.** { *; }
-keep,allowobfuscation,allowshrinking class io.github.jan.supabase.** { *; }
-keep,allowobfuscation,allowshrinking class io.ktor.** { *; }
