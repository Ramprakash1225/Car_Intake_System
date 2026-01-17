# Vercel Deployment Setup with GitHub

This project is configured to automatically deploy to Vercel when changes are pushed to the `main` branch on GitHub.

## How It Works

1. **GitHub Actions Workflow**: When you push changes to GitHub, a GitHub Actions workflow automatically:
   - Builds the Flutter web app
   - Deploys it to Vercel production

2. **Automatic Deployment**: Every push to the `main` branch triggers a new deployment.

## Required GitHub Secrets

To enable automatic deployments, you need to add the following secrets to your GitHub repository:

### Steps to Add Secrets:

1. Go to your GitHub repository: https://github.com/Ramprakash1225/Car_Intake_System
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secret:

#### `VERCEL_TOKEN`
- **Value**: `P1wZsisSXR5cbG6EVII5VaPV`
- **Description**: Vercel authentication token

## Manual Deployment (Alternative)

If you prefer to deploy manually or if GitHub Actions is not set up:

```bash
# 1. Build the Flutter web app
flutter build web --release

# 2. Deploy to Vercel
cd build/web
vercel --prod --token P1wZsisSXR5cbG6EVII5VaPV --yes
```

## Current Deployment Status

- **Production URL**: https://ai-car-intake.vercel.app
- **Project ID**: prj_EWghzFECIrdfkdct7DPSohbwcOQg
- **Organization ID**: team_JIWhH03ZJ4w1Zjb8H4r8FuqD

## Troubleshooting

### If deployments don't trigger automatically:
1. Check GitHub Actions tab in your repository
2. Verify that the `VERCEL_TOKEN` secret is set correctly
3. Check the workflow logs for any errors

### If build fails:
- Ensure Flutter is properly installed in the GitHub Actions environment
- Check that all dependencies are listed in `pubspec.yaml`
- Verify that the build command works locally first

