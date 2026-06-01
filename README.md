# 📱 App Store — GitHub-Powered Flutter App Store

> A self-hosted Android app store built with Flutter. Uses a GitHub repository as its backend — no server required. Browse, download, and manage APKs with a polished, Play Store-inspired UI.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

---

## ✨ Features

### Store
- **Home feed** — Featured apps, Editor's Choice, and Trending sections with shimmer loading
- **24 categories** — Games, Social, Productivity, Entertainment, Tools, and more
- **Search** — Full-text search with persistent search history
- **App detail pages** — Screenshots, promo video, ratings, reviews, version history, and permission breakdown
- **Collections** — Curated groups of apps pulled from your GitHub repo
- **Wishlist & Favorites** — Save apps locally for later

### Downloads
- **APK download manager** — Real-time progress tracking with pause, resume, and cancel support
- **Concurrent queue** — Up to 3 simultaneous downloads; extras queued automatically
- **Background updates** — Silently checks for and downloads updates to installed apps
- **Download history** — Tracks all APKs saved to device

### Security
- **APK integrity scan** — SHA-256 hash verification and APK header validation on every download
- **Signature verification** — Compares file hash against the expected signature from your store manifest
- **Permission analyzer** — Flags dangerous permissions (camera, SMS, location, etc.) with plain-language descriptions and a Low / Medium / High risk score

### Settings & Customization
- **Light / Dark / System theme**
- **GitHub repository config** — Change owner, repo, branch, and optional PAT at runtime without rebuilding
- **WiFi-only downloads**
- **Auto-update and background update toggles**
- **Notification preferences**

### Self-Update
The app store can update itself. Tag a release `appstore-v1.2.3` in your GitHub repo with an APK asset and the app will detect and offer the update automatically.

---

## 🏗️ Architecture

```
lib/
├── config/
│   ├── app_constants.dart      # App name, version, category list, architectures
│   └── github_config.dart      # GitHub API base URLs and auth headers
├── models/
│   └── app_model.dart          # AppModel, AppReview, AppVersion, DownloadTask, etc.
├── providers/
│   ├── app_provider.dart       # App list, search, filters, update state (ChangeNotifier)
│   └── theme_provider.dart     # Theme mode persistence
├── screens/
│   ├── home/                   # Today feed
│   ├── categories/             # Category grid
│   ├── search/                 # Search + history
│   ├── app_detail/             # Full app page
│   ├── downloads/              # Download manager
│   ├── wishlist/               # Saved apps
│   ├── settings/               # Preferences
│   ├── main_shell.dart         # Bottom navigation shell
│   └── splash_screen.dart      # Animated splash
├── services/
│   ├── github_service.dart     # GitHub API: fetch apps, releases, updates
│   ├── download_service.dart   # Dio-based download queue
│   ├── security_service.dart   # APK scanning and permission analysis
│   └── storage_service.dart    # SharedPreferences wrapper
├── themes/
│   └── app_theme.dart          # Light and dark MaterialTheme definitions
└── widgets/
    ├── app_card/               # AppCard, FeaturedCard, HorizontalAppList
    └── shimmer/                # ShimmerLoading skeleton screens
```

State is managed with `provider`. Persistence uses `shared_preferences`. Downloads use `dio`.

---

## 📦 GitHub Repository Structure

Your GitHub repo acts as the backend. It must contain a `store/` folder at the root:

```
your-repo/
├── store/
│   ├── apps.json           # Array of app metadata objects
│   ├── collections.json    # Array of curated collections
│   └── config.json         # Optional store-wide configuration
```

APK files are served via **GitHub Releases**. Tag releases using the convention `appname-v1.2.3` and attach the `.apk` as a release asset. The app store resolves download URLs automatically.

### `apps.json` schema

```json
[
  {
    "id": "myapp",
    "name": "My App",
    "package_name": "com.example.myapp",
    "developer": "Your Name",
    "developer_email": "you@example.com",
    "description": "Full description shown on the detail page.",
    "short_description": "One-line summary.",
    "icon_url": "https://raw.githubusercontent.com/.../icon.png",
    "screenshots": ["https://...", "https://..."],
    "promo_video_url": null,
    "category": "tools",
    "tags": ["utility", "offline"],
    "version": "1.0.0",
    "version_code": "1",
    "changelog": "Initial release.",
    "rating": 4.5,
    "rating_count": 120,
    "download_count": 5000,
    "size": 8192,
    "min_sdk": "21",
    "permissions": [
      "android.permission.INTERNET",
      "android.permission.CAMERA"
    ],
    "age_rating": "Everyone",
    "updated_at": "2025-05-01T00:00:00Z",
    "created_at": "2025-01-01T00:00:00Z",
    "download_url": "",
    "architecture": "universal",
    "is_editor_choice": false,
    "is_trending": true,
    "is_featured": false,
    "signature": "",
    "reviews": [],
    "version_history": []
  }
]
```

Leave `download_url` empty and the service will resolve it automatically from a matching GitHub Release (`myapp-v1.0.0`).

### Release tagging convention

| App ID | Version | Expected tag |
|---|---|---|
| `myapp` | `1.0.0` | `myapp-v1.0.0` |
| `myapp` | `2.1.3` | `myapp-v2.1.3` |
| App Store itself | `1.1.0` | `appstore-v1.1.0` |

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Android SDK (API 21+)
- A GitHub repository set up as described above

### 1. Clone

```bash
git clone https://github.com/your-username/app-store.git
cd app-store
```

### 2. Configure your GitHub backend

Open `lib/config/github_config.dart` and fill in your details:

```dart
static final GithubConfig defaultConfig = GithubConfig(
  owner: 'your-github-username',   // ← Your GitHub username or org
  repo: 'your-repo-name',          // ← The repo containing store/
  branch: 'main',
  token: null,                     // ← Optional: PAT for private repos
);
```

> You can also change this at runtime in the app's **Settings → GitHub Repository**.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run

```bash
# Debug on a connected device
flutter run

# Release APK
flutter build apk --release
```

---

## 📋 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `dio` | APK downloads with progress |
| `shared_preferences` | Local persistence |
| `http` | GitHub API requests |
| `path_provider` | App documents directory |
| `crypto` | SHA-256 APK hashing |
| `intl` | Date formatting |

---

## 🔒 Security Notes

- APK files are scanned for a valid ZIP header (`0x50`) and minimum file size before installation
- SHA-256 hashes are computed and can be matched against the `signature` field in `apps.json`
- Permissions are analyzed and categorized into Low / Medium / High risk before a user installs
- For private repos, store your PAT in the in-app settings rather than hardcoding it

---

## 🛠️ Customization

**Add a category** — Extend the `categories` list in `AppConstants`:

```dart
CategoryInfo('fitness', 'Fitness', Icons.fitness_center, Color(0xFF4CAF50)),
```

**Change the self-update tag prefix** — Update `selfUpdateTagPrefix` in `AppConstants`:

```dart
static const String selfUpdateTagPrefix = 'mystore-v';
```

**Change concurrent download limit** — Edit the threshold in `DownloadService._processQueue()`:

```dart
if (active < 3) { // ← change this number
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -m 'Add my feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  Built with Flutter · Backed by GitHub · No server needed.
</div>
