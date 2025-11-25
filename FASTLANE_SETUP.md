# Fastlane Setup Guide for Ionic + Capacitor

## Initial Configuration

### 1. iOS Setup

#### Prerequisites:

- Active Apple Developer account
- Xcode installed
- Certificates and provisioning profiles configured

#### Steps:

1. **Setup Apple Developer Account:**

   ```bash
   cd ios/App
   fastlane fastlane-credentials add --username your-apple-id@email.com
   ```

2. **Setup Match (Code Signing):**

   ```bash
   # Create private repository for certificates
   fastlane match init

   # Generate development certificates
   fastlane match development

   # Generate distribution certificates
   fastlane match appstore
   ```

3. **Update Appfile with your data:**
   - `app_identifier`: Your bundle ID
   - `apple_id`: Your Apple ID
   - `team_id`: Your Developer Team ID

### 2. Android Setup

#### Prerequisites:

- Google Play Console account
- Google Cloud Project configured
- Service Account JSON key

#### Steps:

1. **Create Service Account in Google Cloud:**

   - Go to Google Cloud Console
   - Create a new project or use an existing one
   - Enable Google Play Android Developer API
   - Create Service Account and download the JSON key

2. **Configure Google Play Console:**

   - Go to Google Play Console → Setup → API access
   - Link your Google Cloud project
   - Grant access to the Service Account

3. **Setup Fastlane:**

   ```bash
   cd android
   fastlane supply init
   ```

4. **Update Appfile with your data:**
   - `json_key_file`: Path to the Service Account JSON file
   - `package_name`: Your Android package name

## Available Commands

### iOS:

```bash
# Beta deployment to TestFlight
npm run deploy:ios:beta

# Release to App Store
npm run deploy:ios:release

# Build only
cd ios/App && fastlane build

# Refresh provisioning profiles
cd ios/App && fastlane refresh_profiles
```

### Android:

```bash
# Internal testing
npm run deploy:android:internal

# Beta deployment
npm run deploy:android:beta

# Production release
npm run deploy:android:release

# Build APK only
cd android && fastlane build_release

# Build AAB only
cd android && fastlane build_aab
```

## Environment Variables

Copy `.env.example` to `.env.local` and configure your values:

```bash
cp .env.example .env.local
```

## Troubleshooting

### iOS:

- **Code signing issues**: Run `fastlane match development` and `fastlane match appstore`
- **Team ID issues**: Verify in Apple Developer Portal
- **Build failures**: Check that Xcode is up to date

### Android:

- **Upload failures**: Verify Service Account permissions
- **Signing issues**: Make sure you have signing configured in `android/app/build.gradle`
- **API issues**: Verify that Google Play Android Developer API is enabled

## CI/CD Integration

### GitHub Actions Example:

```yaml
name: Deploy to Stores
on:
  push:
    tags: ['v*']

jobs:
  deploy-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Deploy to TestFlight
        run: npm run deploy:ios:beta
        env:
          FASTLANE_APPLE_ID: ${{ secrets.APPLE_ID }}
          FASTLANE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}

  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Deploy to Play Store
        run: npm run deploy:android:beta
        env:
          ANDROID_JSON_KEY_FILE: ${{ secrets.ANDROID_JSON_KEY_FILE }}
```

## Next Steps

1. Configure your credentials following this guide
2. Test with `fastlane build` before deploying
3. Setup CI/CD to automate deployments
4. Add Slack notifications if needed
