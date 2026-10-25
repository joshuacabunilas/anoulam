# AnoUlam

Find dishes you can cook from the ingredients you already have. Add what's in your kitchen, and AnoUlam suggests recipes, best match first, showing what you have and what you still need. Strong on Filipino dishes, free, no account.

- **App:** Flutter, Android only (clean architecture, BLoC, injectable, Dio).
- **Backend:** FastAPI in [`backend/`](backend/) with a free SQLite recipe database (111 recipes) and recipe photos from Wikimedia Commons ([credits](backend/data/images/CREDITS.md)).

## Run locally

1. Start the backend:

   ```
   cd backend
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   uvicorn app.main:app --reload
   ```

2. Run the app on the Android emulator (defaults to `ENV=dev`, the local backend at `http://10.0.2.2:8000`):

   ```
   flutter run
   ```

   On a physical phone, point it at your computer: `flutter run --dart-define=API_BASE_URL=http://<your-pc-ip>:8000`.

Tests: `flutter test` (app) and `pytest` in `backend/`.

## Deploy (free)

### Backend on Render

[`render.yaml`](render.yaml) describes the service. In [Render](https://render.com): **New > Blueprint**, connect this GitHub repo, and apply. It deploys `backend/` on the free plan and redeploys on every push to `main`.

The free plan sleeps after 15 minutes without traffic and takes about a minute to wake; the app shows "Waking up the recipe server..." meanwhile.

The app expects the backend at `https://anoulam-api.onrender.com` (`ApiHelper.baseUrlProd`). If Render assigns a different address, update that constant.

### Android app

Release builds are signed with an upload key kept outside the repo. `android/key.properties` (git-ignored) points at it:

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/Users/IT/keys/anoulam-upload.jks
```

Back up the `.jks` file and its password somewhere safe: updates to the installed app must be signed with the same key. Without `key.properties`, release builds fall back to the debug key.

Build the APK against the live backend:

```
flutter build apk --release --dart-define=ENV=prod
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`. Share it directly (e.g. GitHub Releases) for free; Google Play needs a one-time $25 developer account.

## Regenerating code and assets

- Dependency injection: `dart run build_runner build --delete-conflicting-outputs`
- App icon: `dart run flutter_launcher_icons` (sources in `assets/brand/`)
- Splash screen: `dart run flutter_native_splash:create`
