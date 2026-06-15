# PWA assets

Place installable app assets in this folder.

Recommended files:

- `icon-192.png` - square PNG, 192x192
- `icon-512.png` - square PNG, 512x512
- `maskable-icon-512.png` - 512x512 PNG with safe padding for Android maskable icons
- `apple-touch-icon.png` - 180x180 PNG for iOS home screen

Screenshots can go in:

- `public/pwa/screens/home-wide.png` - 1280x720 or similar desktop screenshot
- `public/pwa/screens/home-mobile.png` - 390x844 or similar mobile screenshot

After adding those files, update `app/views/pwa/manifest.json.erb` to point icons and screenshots to `/pwa/...`.
