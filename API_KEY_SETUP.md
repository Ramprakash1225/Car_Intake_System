# API Key Configuration Guide

## Overview
This application uses Google Gemini AI for car image analysis. You need to configure a valid Gemini API key for the AI features to work properly.

## Step 1: Get a Gemini API Key

### Option A: Google AI Studio (Recommended)
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"** or **"Get API Key"**
4. Select or create a Google Cloud project
5. Copy the generated API key (it will look like: `AIzaSy...`)

### Option B: Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** > **Credentials**
3. Click **"Create Credentials"** > **"API Key"**
4. Enable the **Generative Language API** for your project
5. Copy the API key

## Step 2: Configure the API Key

### Method 1: Using .env File (Recommended)

1. **Create a `.env` file** in the root directory of your project:
   ```
   GEMINI_API_KEY=your_api_key_here

   ```

2. **Copy from example:**
   ```bash
   # On Windows PowerShell:
   Copy-Item .env.example .env
   
   # On Linux/Mac:
   cp .env.example .env
   ```

3. **Edit the `.env` file** and replace `your_api_key_here` with your actual API key:
   ```
   GEMINI_API_KEY=your_actual_api_key_here

   ```

4. **The `.env` file is already in `.gitignore`** - your API key will not be committed to version control.

### Method 2: Using Environment Variables (Alternative)

You can also set the API key as an environment variable:

**Windows PowerShell:**
```powershell
$env:GEMINI_API_KEY="your_api_key_here"
flutter run -d chrome
```

**Linux/Mac:**
```bash
export GEMINI_API_KEY="your_api_key_here"
flutter run -d chrome
```

### Method 3: Using --dart-define (For Production)

```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_api_key_here
```

## Step 3: Verify Configuration

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

3. **Test the API:**
   - Go to the "Analyze Car" screen
   - Upload a car image
   - Click "Analyze Car"
   - If configured correctly, you should see real AI analysis results
   - If not configured, you'll see default/fallback values

## Troubleshooting

### Error: 401 Unauthorized
- **Cause:** Invalid or expired API key
- **Solution:** 
  - Verify your API key is correct
  - Check if the Generative Language API is enabled in Google Cloud Console
  - Make sure you're using a Gemini API key (starts with `AIzaSy`), not a Vertex AI key

### Error: API key not found
- **Cause:** `.env` file not loaded or API key not set
- **Solution:**
  - Ensure `.env` file exists in the project root
  - Check that the file contains `GEMINI_API_KEY=your_api_key_here`
  - Restart the Flutter app after creating/editing `.env`

### Error: Quota exceeded
- **Cause:** API usage limit reached
- **Solution:**
  - Check your Google Cloud billing
  - Review API quotas in Google Cloud Console
  - Consider upgrading your plan

## Security Best Practices

1. **Never commit `.env` file** - It's already in `.gitignore`
2. **Use different API keys** for development and production
3. **Restrict API key** to specific domains/IPs in Google Cloud Console
4. **Monitor API usage** regularly
5. **Rotate API keys** periodically

## Current API Key Format

The current hardcoded key (`AQ.Ab8RN6IbNbKXY1pBCxno_I_ZorqAsDy5IQvoqfCom9Fg55eClw`) appears to be a Vertex AI access token, not a Gemini API key. 

**For the `google_generative_ai` package to work, you need a Gemini API key that:**
- Starts with `AIzaSy...`
- Is obtained from Google AI Studio
- Has the Generative Language API enabled

## Next Steps

1. Get your Gemini API key from Google AI Studio
2. Create `.env` file with your API key
3. Run `flutter pub get` to install dependencies
4. Restart your Flutter app
5. Test the analyze car feature

## Support

If you encounter issues:
1. Check the console for error messages
2. Verify API key format (should start with `AIzaSy`)
3. Ensure the Generative Language API is enabled
4. Check your Google Cloud billing status

