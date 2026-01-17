# Troubleshooting: Localhost Connection Refused

## Problem
You're getting a "localhost refuse to connect" error when trying to access the Flutter web app.

## Root Cause
The Flutter development server is not running. This app needs to be started using Flutter's web development server.

## Solutions

### Solution 1: Install Flutter and Run the Dev Server (Recommended)

1. **Install Flutter** (if not already installed):
   - Download from: https://docs.flutter.dev/get-started/install/windows
   - Extract to a location like `C:\src\flutter` or `C:\flutter`
   - Add Flutter to your PATH:
     - Open System Properties → Environment Variables
     - Add `C:\src\flutter\bin` (or your Flutter path) to PATH
     - Restart your terminal

2. **Verify Flutter Installation**:
   ```powershell
   flutter doctor
   ```

3. **Get Dependencies**:
   ```powershell
   cd C:\Users\Qumarionix\Desktop\AIpoweredcarintakeflutter
   flutter pub get
   ```

4. **Run the App**:
   ```powershell
   flutter run -d chrome --web-port=5173
   ```
   
   Or for web-server:
   ```powershell
   flutter run -d web-server --web-port=5173
   ```

5. **Access the App**:
   - Open your browser and go to: `http://localhost:5173`

### Solution 2: Build and Serve with a Simple HTTP Server

If you have Flutter installed but prefer a static build:

1. **Build the Web Version**:
   ```powershell
   flutter build web
   ```

2. **Serve with Python** (if Python is installed):
   ```powershell
   cd build\web
   python -m http.server 5173
   ```

3. **Or Serve with Node.js** (if Node.js is installed):
   ```powershell
   cd build\web
   npx http-server -p 5173
   ```

### Solution 3: Check if Flutter is Installed Elsewhere

If Flutter is installed but not in PATH, you can:

1. **Find Flutter Installation**:
   - Search for `flutter.bat` in your system
   - Common locations:
     - `C:\Users\<YourUsername>\flutter\bin`
     - `C:\src\flutter\bin`
     - `C:\flutter\bin`

2. **Use Full Path**:
   ```powershell
   C:\path\to\flutter\bin\flutter.bat run -d chrome --web-port=5173
   ```

3. **Or Add to PATH Temporarily**:
   ```powershell
   $env:PATH += ";C:\path\to\flutter\bin"
   flutter run -d chrome --web-port=5173
   ```

## Quick Check Commands

Run these to diagnose:

```powershell
# Check if Flutter is accessible
flutter --version

# Check Flutter installation
flutter doctor

# Check if port 5173 is in use
netstat -ano | findstr :5173

# Check available devices
flutter devices
```

## Default Credentials

Once the app is running:
- **Username**: `admin`
- **Password**: `admin123`

## Still Having Issues?

1. Make sure no firewall is blocking port 5173
2. Try a different port: `flutter run -d chrome --web-port=8080`
3. Check if Chrome is installed (required for `-d chrome`)
4. Try `flutter run -d web-server` instead of `-d chrome`

