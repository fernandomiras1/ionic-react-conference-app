# GitHub Actions Setup for Fastlane

This guide explains how to configure GitHub Actions to automatically build and deploy your Ionic app.

## 📋 Prerequisites

Before setting up GitHub Actions, make sure you have:

1. ✅ Fastlane configured locally (see `FASTLANE_SETUP.md`)
2. ✅ Certificates and provisioning profiles set up (iOS)
3. ✅ Google Play Service Account created (Android - for deployment)
4. ✅ App created in App Store Connect and Google Play Console (for deployment)

## � Available Workflows

### 1. iOS Build (`ios-fastlane.yml`)

**Purpose:** Build iOS app on every push/PR

**Triggers:**

- Push to `main` branch
- Pull requests
- Manual trigger via GitHub UI

**What it does:**

1. Installs Node.js dependencies
2. Builds the web app (`npm run build`)
3. Syncs Capacitor (`npx cap sync ios`)
4. Installs CocoaPods dependencies
5. Builds iOS app using Fastlane

**Secrets needed for basic build:**

- `MATCH_GIT_URL` (optional, only if using match)
- `MATCH_PASSWORD` (optional, only if using match)
- `FASTLANE_APP_IDENTIFIER`

### 2. Android Build (`android-fastlane.yml`)

**Purpose:** Build Android APK on every push/PR

**Triggers:**

- Push to `main` branch
- Pull requests
- Manual trigger via GitHub UI

**What it does:**

1. Installs Node.js dependencies
2. Builds the web app
3. Syncs Capacitor
4. Builds Android release APK
5. Uploads APK as artifact (downloadable from Actions tab)

**No secrets needed for basic build**

## 🔐 GitHub Secrets Configuration (Optional)

These secrets are only needed if you want to deploy to stores automatically.

Go to: Repository → Settings → Secrets and variables → Actions → New repository secret

### iOS Secrets:

| Secret Name               | Description                    | How to Get                                             |
| ------------------------- | ------------------------------ | ------------------------------------------------------ |
| `FASTLANE_APPLE_ID`       | Your Apple ID email            | Your Apple Developer account email                     |
| `FASTLANE_PASSWORD`       | Apple ID password              | Your Apple account password (or app-specific password) |
| `FASTLANE_TEAM_ID`        | Developer Team ID              | Found in Apple Developer Portal → Membership           |
| `FASTLANE_ITC_TEAM_ID`    | App Store Connect Team ID      | Usually same as TEAM_ID, or found in App Store Connect |
| `FASTLANE_APP_IDENTIFIER` | Bundle ID                      | e.g., `com.fernandomiras.ionicconference`              |
| `MATCH_PASSWORD`          | Password for certificates repo | Password you set when running `fastlane match init`    |
| `MATCH_GIT_URL`           | Git URL for certificates       | e.g., `https://github.com/yourusername/certificates`   |

### Android Secrets:

| Secret Name                     | Description                      | How to Get                                             |
| ------------------------------- | -------------------------------- | ------------------------------------------------------ |
| `ANDROID_JSON_KEY_FILE_CONTENT` | Google Play Service Account JSON | Copy entire content of `google-play-api-key.json` file |
| `ANDROID_PACKAGE_NAME`          | Android package name             | e.g., `com.fernandomiras.ionicconference`              |

### Optional Secrets:

| Secret Name       | Description                               |
| ----------------- | ----------------------------------------- |
| `SLACK_URL`       | Slack webhook URL for notifications       |
| `FIREBASE_APP_ID` | Firebase App ID for Firebase Distribution |
| `FIREBASE_TOKEN`  | Firebase CI token                         |

## 🚀 Available Workflows

### 1. Deploy iOS to TestFlight

**File:** `.github/workflows/deploy-ios.yml`

**Triggers:**

- Push to `main` branch
- Push tags starting with `v*` (e.g., `v1.0.0`)
- Manual trigger via GitHub UI

**What it does:**

1. Installs Node.js dependencies
2. Builds the web app
3. Syncs Capacitor
4. Installs CocoaPods dependencies
5. Signs the app with certificates
6. Builds and uploads to TestFlight

**Run manually:**

```bash
# Via GitHub UI: Actions → Deploy iOS to TestFlight → Run workflow
```

### 2. Deploy Android to Play Store

**File:** `.github/workflows/deploy-android.yml`

**Triggers:**

- Push to `main` branch
- Push tags starting with `v*`
- Manual trigger via GitHub UI

**What it does:**

1. Installs Node.js dependencies
2. Builds the web app
3. Syncs Capacitor
4. Builds Android App Bundle (AAB)
5. Uploads to Play Store Beta track

## 📝 How to Use

### First-Time Setup:

1. **Configure all GitHub Secrets** (see table above)

2. **Create certificates repository for iOS** (private repo):

   ```bash
   # Create a new private GitHub repo called 'certificates'
   # Then run locally:
   cd ios/App
   fastlane match init
   # Follow prompts and enter your certificates repo URL
   ```

3. **Generate certificates** (run locally first time):

   ```bash
   cd ios/App
   fastlane match appstore
   ```

4. **Test workflows locally** before pushing:

   ```bash
   # iOS
   npm run deploy:ios:beta

   # Android
   npm run deploy:android:beta
   ```

### Deploy a New Version:

**Option 1: Push a tag**

```bash
git tag v1.0.1
git push origin v1.0.1
```

**Option 2: Push to main**

```bash
git push origin main
```

**Option 3: Manual trigger**

- Go to GitHub → Actions
- Select workflow
- Click "Run workflow"

## 🔧 Troubleshooting

### iOS Issues:

**Code signing failed:**

- Verify `MATCH_PASSWORD` is correct
- Check certificates repo access
- Run `fastlane match appstore` locally first

**Build failed:**

- Check Xcode version in workflow matches your local
- Verify all secrets are set correctly
- Check build logs in Actions tab

### Android Issues:

**Upload to Play Store failed:**

- Verify Google Play Service Account has correct permissions
- Check JSON key content is valid (entire file content)
- Ensure app is created in Play Console

**Gradle build failed:**

- Check Java version (should be 17)
- Verify signing configuration in `build.gradle`

## 🔄 Customizing Workflows

### Change deployment track:

**iOS - Deploy to production:**

```yaml
run: bundle exec fastlane release
```

**Android - Deploy to different tracks:**

```yaml
run: bundle exec fastlane internal  # Internal testing
run: bundle exec fastlane alpha     # Alpha
run: bundle exec fastlane beta      # Beta (default)
run: bundle exec fastlane production # Production
```

### Add Slack notifications:

1. Add `SLACK_URL` secret
2. Notifications are already configured in Fastfiles

### Run only on tags:

Remove the `branches` trigger and keep only `tags`:

```yaml
on:
  push:
    tags:
      - 'v*'
```

## 📊 Monitoring Deployments

- **View workflow runs:** Repository → Actions tab
- **Download build logs:** Failed runs have artifacts attached
- **TestFlight status:** Check App Store Connect
- **Play Store status:** Check Google Play Console

## 🔒 Security Best Practices

1. ✅ Never commit secrets to the repository
2. ✅ Use repository secrets (not environment secrets) for sensitive data
3. ✅ Rotate passwords regularly
4. ✅ Use app-specific passwords for Apple ID
5. ✅ Keep certificates repository private
6. ✅ Limit Service Account permissions to only what's needed

## 📚 Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Capacitor CI/CD Guide](https://capacitorjs.com/docs/guides/ci-cd)
- [Apple App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Google Play Developer API](https://developers.google.com/android-publisher)
