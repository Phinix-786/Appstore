# GitHub Repository Structure for App Store

Your GitHub repository should follow this structure for the app store to discover and display your apps:

## Directory Structure

```
your-repo/
├── apps/
│   ├── WhatsApp/
│   │   ├── icon.png                    # App icon (512x512 recommended)
│   │   ├── metadata.json               # App metadata
│   │   ├── screenshots/                # App screenshots
│   │   │   ├── screen1.png
│   │   │   ├── screen2.png
│   │   │   └── screen3.png
│   │   └── releases/                   # APK files
│   │       ├── whatsapp-v2.24.1.apk
│   │       └── whatsapp-v2.24.0.apk
│   ├── Instagram/
│   │   ├── icon.png
│   │   ├── metadata.json
│   │   ├── screenshots/
│   │   └── releases/
│   └── ...
├── store/
│   ├── apps.json          # (Optional) Master app list
│   ├── collections.json   # (Optional) Curated collections
│   └── config.json        # (Optional) Store configuration
└── README.md
```

## metadata.json Format

```json
{
  "name": "WhatsApp",
  "package_name": "com.whatsapp",
  "developer": "Meta Platforms",
  "developer_email": "support@whatsapp.com",
  "description": "WhatsApp Messenger is a FREE messaging app...",
  "short_description": "Simple. Reliable. Private.",
  "category": "communication",
  "tags": ["messaging", "chat", "video-calls"],
  "version": "2.24.1",
  "version_code": "241",
  "changelog": "Bug fixes and performance improvements",
  "rating": 4.5,
  "rating_count": 1500000,
  "download_count": 5000000000,
  "size": 65536,
  "min_sdk": "21",
  "permissions": [
    "android.permission.INTERNET",
    "android.permission.CAMERA",
    "android.permission.RECORD_AUDIO"
  ],
  "age_rating": "Everyone",
  "architecture": "universal",
  "is_editor_choice": true,
  "is_trending": true,
  "is_featured": false,
  "signature": "",
  "download_url": "",
  "promo_video_url": "https://youtube.com/watch?v=...",
  "reviews": [
    {
      "id": "r1",
      "user_name": "John",
      "rating": 5.0,
      "comment": "Great app!",
      "date": "2024-01-15T00:00:00Z",
      "developer_reply": "Thank you!"
    }
  ],
  "version_history": [
    {
      "version": "2.24.0",
      "version_code": "240",
      "changelog": "New features added",
      "date": "2024-01-01T00:00:00Z",
      "size": 64000,
      "download_url": ""
    }
  ]
}
```

## store/apps.json (Optional - Master List)

If you provide this file, the app store will use it instead of scanning individual folders:

```json
[
  {
    "id": "whatsapp",
    "name": "WhatsApp",
    "package_name": "com.whatsapp",
    ...all metadata fields...
  }
]
```

## store/collections.json (Optional)

```json
[
  {
    "id": "best-messaging",
    "title": "Best Messaging Apps",
    "description": "Top picks for staying connected",
    "banner_url": "https://...",
    "app_ids": ["whatsapp", "telegram", "signal"]
  }
]
```

## store/config.json (Optional)

```json
{
  "store_name": "My App Store",
  "store_description": "The best apps, curated for you",
  "featured_apps": ["whatsapp", "instagram"],
  "banner_url": ""
}
```

## Notes

- The app store will first try to load `store/apps.json`
- If not found, it scans each folder under `apps/`
- APKs can be in `releases/` folder OR in GitHub Releases (tagged with app name)
- Icons should be PNG format, 512x512px recommended
- Screenshots should be phone-resolution PNG/JPG images
- The `download_url` in metadata is optional - if empty, the store looks for APKs in the releases folder or GitHub Releases
