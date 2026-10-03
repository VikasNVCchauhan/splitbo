---
name: project-splitbo
description: Splitbo app status, infrastructure, credentials, CI/CD config, and Firebase setup
metadata:
  type: project
---

# Splitbo Project State

## Live URL
https://vikasnvcchauhan.github.io/splitbo/

## Repo
https://github.com/VikasNVCchauhan/splitbo

## Stack
- Flutter Web + Melos monorepo
- Firebase Auth (Google Sign-In via `signInWithPopup` on web)
- Firestore (real-time streams)
- GitHub Actions → GitHub Pages (auto-deploy on push to main)

## Firebase Project
- Project ID: `splitbo`
- Console: https://console.firebase.google.com/project/splitbo
- Service account email: `firebase-deploye@splitbo.iam.gserviceaccount.com`
- Service account key: stored in GitHub Secret `FIREBASE_SERVICE_ACCOUNT` (NOT in repo)
- Key was generated 2026-09-20 from Firebase Console → Project Settings → Service Accounts

## CI/CD
- GitHub Actions workflow: `.github/workflows/deploy.yml`
- On push to `main`:
  1. Builds Flutter web with `--no-tree-shake-icons --base-href "/splitbo/"`
  2. Deploys to GitHub Pages
  3. Deploys Firestore indexes + rules to Firebase using `FIREBASE_SERVICE_ACCOUNT` secret
- Firebase deploy uses `w9jds/firebase-action@master` with `GCP_SA_KEY` env var

## Firebase CLI Auth
- Interactive `firebase login` doesn't work in this environment (no interactive terminal)
- Use `GOOGLE_APPLICATION_CREDENTIALS=/tmp/splitbo-service-account.json firebase deploy` for manual local deploys
- Key stored at `/tmp/splitbo-service-account.json` (temp, not persisted — recreate from GitHub Secret if needed)

## Firestore
- Rules: `firebase/firestore.rules` (deployed, production-grade per-collection security)
- Indexes: `firebase/firestore.indexes.json` (deployed)
- Key composite index: `groups` collection — `memberIds` (array-contains) + `createdAt` (descending)
- Dev/prod isolation: `kDebugMode ? 'dev_' : ''` prefix on all collection names

## Google OAuth
- Authorised JavaScript origins must include the browser origin for sign-in to work
- Production: `https://vikasnvcchauhan.github.io` already added
- Local dev: add `http://localhost:3000` per-developer in Google Cloud Console → Credentials

## Auth Guard
- `kDebugMode`: auth guard is skipped — app lands on home screen directly (intentional for local dev)
- Production: unauthenticated users redirected to `/auth/sign-in`

## Brand
- Green: `#C3FD00` (Color(0xFFC3FD00))
- Background: `#000000`
- Surface: `#1A1A1A`

**Why:** Established at project start from marketing assets folder.
**How to apply:** Never use a different green. All accent elements use this exact value.
