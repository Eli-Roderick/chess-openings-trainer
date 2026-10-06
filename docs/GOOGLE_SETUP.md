# Google Drive sync: one-time Google Cloud setup

Sync stores its files in the hidden app folder of your own Google Drive (scope `drive.appdata` only), so the app needs OAuth clients from a Google Cloud project you own. You do this once; it takes about 15 minutes. The code and tests do not need it, only real devices do.

You need: a Google account, the release keystore (`android/release.jks` or wherever you keep it) and the Android debug keystore (`~/.android/debug.keystore`, created by the first debug build).

## 1. Project

1. Open <https://console.cloud.google.com/> and sign in.
2. Project picker (top bar) → **New project** → name it "Repertoire Trainer" → **Create**, then select it.

## 2. Drive API

1. **APIs & Services → Library**.
2. Search "Google Drive API" → open it → **Enable**.

## 3. OAuth consent screen

1. **Google Auth Platform** (or APIs & Services → OAuth consent screen) → **Get started**.
2. App information: app name "Repertoire Trainer", user support email = your address → Next.
3. Audience: **External** → Next. Contact information: your address → Next. Agree to the policy → **Create**.
4. **Data access → Add or remove scopes** → filter for `drive.appdata` → tick `.../auth/drive.appdata` → **Update** → **Save**.
5. **Audience → Test users → Add users** → your Google account → **Save**.
6. **Audience → Publish app** (status "In production"). Do not skip this: in "Testing" status Google expires refresh tokens after 7 days, so you would have to sign in again every week. An unverified app in production still works for you after the "Google hasn't verified this app" screen (**Advanced → Go to Repertoire Trainer**).

## 4. Android client

1. Get the SHA-1 fingerprints:
   ```sh
   keytool -list -v -keystore <path to release.jks> -alias <your alias>
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. **Clients → Create client → Android**: package name `dev.eliroderick.repertoiretrainer`, SHA-1 of the **release** key → **Create**.
3. Create a second Android client the same way with the **debug** SHA-1 (debug builds use it).

The Android clients need no value in the app; Google matches them by package name and signature.

## 5. Web client (its id is the Android `serverClientId`)

1. **Clients → Create client → Web application**, name "Repertoire Trainer server" → **Create**.
2. Copy the **Client ID** (`….apps.googleusercontent.com`). Ignore the secret.

## 6. Desktop client (Windows, Linux development)

1. **Clients → Create client → Desktop app**, name "Repertoire Trainer desktop" → **Create**.
2. Copy the **Client ID** and **Client secret**. Google treats a desktop client secret as not confidential; it is still kept out of the repository.

## 7. Put the values into the build

1. Copy `config/google_oauth.example.json` to `config/google_oauth.json` (gitignored) and fill in:
   ```json
   {
     "GOOGLE_ANDROID_SERVER_CLIENT_ID": "<web client id from step 5>",
     "GOOGLE_DESKTOP_CLIENT_ID": "<desktop client id from step 6>",
     "GOOGLE_DESKTOP_CLIENT_SECRET": "<desktop client secret from step 6>"
   }
   ```
2. Build or run with `--dart-define-from-file=config/google_oauth.json` (see README, "Google Drive sync").
3. For release builds, add the same three values as repository secrets (GitHub → Settings → Secrets and variables → Actions): `GOOGLE_ANDROID_SERVER_CLIENT_ID`, `GOOGLE_DESKTOP_CLIENT_ID`, `GOOGLE_DESKTOP_CLIENT_SECRET`. The release workflow writes the config file from them.

## 8. Check

1. Phone: Settings → Sync and backup → **Sync with Google Drive** → pick your account → allow access. "Last sync" shows a time.
2. Windows: the same switch opens the browser; allow access; the browser says it can be closed. "Last sync" shows a time and your repertoires and stats from the phone appear.
3. Diagnostics (About → tap the version 7 times) → Sync → **List Drive files** shows `rt1-<device>-meta.json.gz` and the monthly `runs` files of both devices.

If sign-in fails on Android with a "developer error", the SHA-1 of the build you installed is not registered (step 4); debug and release builds need their own client.
