# Vercel Configuration for Flutter App

## Current Setup

This project uses **GitHub Actions** to build and deploy to Vercel, because Vercel's build environment doesn't have Flutter installed.

## Important: Disable Vercel's Automatic Builds

Since we're using GitHub Actions for building, you should **disable Vercel's automatic builds** to prevent build failures:

### Steps to Disable Automatic Builds in Vercel:

1. Go to your Vercel project: https://vercel.com/qumarionixs-projects/ai-car-intake
2. Click on **Settings** → **Git**
3. Under **Production Branch**, you'll see the GitHub integration
4. **Option 1 (Recommended)**: Disable automatic deployments
   - Toggle off "Automatic deployments from Git"
   - This way, only GitHub Actions will deploy
   
5. **Option 2**: Keep it enabled but it will fail (harmless)
   - The build will fail, but GitHub Actions will still deploy successfully
   - You can ignore the failed builds

## How It Works Now

1. **You push to GitHub** → Triggers GitHub Actions workflow
2. **GitHub Actions**:
   - Builds Flutter web app
   - Deploys to Vercel using Vercel CLI
3. **Vercel** serves the deployed files

## Manual Deployment

If you need to deploy manually:

```bash
# Build locally
flutter build web --release

# Deploy to Vercel
cd build/web
vercel --prod --token P1wZsisSXR5cbG6EVII5VaPV --yes
```

## Troubleshooting

### If Vercel builds fail:
- This is expected if automatic builds are enabled
- GitHub Actions will still deploy successfully
- You can safely ignore Vercel's build failures

### If GitHub Actions fails:
- Check that `VERCEL_TOKEN` secret is set in GitHub
- Verify the token is correct
- Check the Actions logs for specific errors

