# Gaia Expo Preview

This Expo app is a thin mobile wrapper around the Gaia web prototype. It loads the stable Vercel URL `https://gaia-neon.vercel.app/` in a full-screen `WebView` so you can review the latest deployed experience in Expo Go without browser tabs or mobile browser chrome getting in the way.

## What updates automatically

- If `EXPO_PUBLIC_GAIA_URL` points at your production Vercel domain, Expo Go always shows the latest production deploy.
- If it points at a stable branch domain, Expo Go always shows the latest deploy for that branch.
- You only change the Expo app when the shell itself changes. Normal Gaia web deploys update automatically behind the same URL.

## First-time setup

1. Open a terminal in this folder:

   ```bash
   cd "/Users/micahhoang/My Drive/CD5 VXD/Gaia-Prototype/expo-preview"
   ```

2. Copy the env template:

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and set:

   ```bash
   EXPO_PUBLIC_GAIA_URL=https://gaia-neon.vercel.app/
   EXPO_PUBLIC_GAIA_LABEL=Production
   ```

4. Start Expo:

   ```bash
   npm run start:tunnel
   ```

   Use `start:tunnel` when phone and laptop networking is finicky. On a clean local network, `npm start` or `npm run start:lan` is also fine.

5. Open Expo Go on your phone and scan the QR code.

## Which Vercel URL to use

- Production preview: use your main production domain.
- Branch preview: use a stable branch URL if you want the app to follow the latest deploy from a branch.

Suggested labels:

- `Production`
- `Main Branch`
- `Design Review`

## Day-to-day use

1. Push Gaia changes to the branch or production flow that your chosen Vercel URL tracks.
2. Wait for Vercel to finish deploying.
3. Open the Expo Go wrapper.
4. Pull down to refresh if the latest deploy is not already visible.

## If you change the target URL

1. Update `.env`.
2. Restart Expo so the new `EXPO_PUBLIC_*` values are picked up.

## Troubleshooting

- Blank screen: confirm `EXPO_PUBLIC_GAIA_URL` is reachable in your phone browser.
- Old version still showing: pull to refresh inside the app, then fully reload the Expo session if needed.
- QR code connection issues: use `npm run start:tunnel`.
- Dependency mismatch: run `npx expo install --fix`.
