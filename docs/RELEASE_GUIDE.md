# Joyscoop: Production Release & Deployment Guide

## 1. Android Release Signing Setup

### A. Generate Keystore
Run the following command in terminal to create an upload keystore:
```bash
keytool -genkey -v -keystore android/app/joyscoop-release.keystore -alias joyscoop -keyalg RSA -keysize 2048 -validity 10000
```

### B. Configure `key.properties`
Create `android/key.properties` (ensure this is listed in `.gitignore`):
```properties
storePassword=<YOUR_STORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=joyscoop
storeFile=joyscoop-release.keystore
```

### C. Configure `android/app/build.gradle.kts`
Add key properties loading and signingConfig:
```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### D. Build Release APK
Run:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```
The output APK will be available at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 2. Supabase Production Settings Checklist

- [x] **Disable Public Signups**: Go to Authentication -> Providers -> Email -> disable "Allow new users to sign up".
- [x] **RLS Verified**:
  - `products`: Select only for authenticated users.
  - `profiles`: Select for authenticated users; update for `auth.uid() = id`.
  - `sales_events`: Append-only (select & insert enabled, no update or delete).
- [x] **Trigger Safeguards**: Prevent decrement below 0 with `trg_sales_events_before_insert`.
- [x] **Realtime Enabled**: `alter publication supabase_realtime add table public.sales_events;`.
- [x] **Database Backups**: Enable Supabase automated daily backups and Point-In-Time Recovery (PITR).
- [x] **Key Handling**: Use Anon Key only inside client builds; keep Service Role Key strictly private.

