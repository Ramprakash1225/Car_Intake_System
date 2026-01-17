# Flutter Web App Startup Script
# This script helps find and run the Flutter web app

Write-Host "=== Flutter Web App Startup Script ===" -ForegroundColor Cyan
Write-Host ""

# Function to find Flutter
function Find-Flutter {
    $commonPaths = @(
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "C:\src\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
        "$env:ProgramFiles\flutter\bin\flutter.bat"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Try to find in PATH
    $flutterInPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterInPath) {
        return "flutter"
    }
    
    return $null
}

# Find Flutter
Write-Host "Searching for Flutter installation..." -ForegroundColor Yellow
$flutterPath = Find-Flutter

if (-not $flutterPath) {
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "Or if Flutter is installed, add it to your PATH environment variable." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After installation, run this script again." -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ Found Flutter at: $flutterPath" -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
$currentDir = Get-Location
$pubspecExists = Test-Path "pubspec.yaml"

if (-not $pubspecExists) {
    Write-Host "⚠️  Warning: pubspec.yaml not found in current directory" -ForegroundColor Yellow
    Write-Host "Current directory: $currentDir" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
if ($flutterPath -eq "flutter") {
    flutter pub get
} else {
    & $flutterPath pub get
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Check available devices
Write-Host "Checking available devices..." -ForegroundColor Yellow
if ($flutterPath -eq "flutter") {
    flutter devices
} else {
    & $flutterPath devices
}

Write-Host ""
Write-Host "Starting Flutter web app on http://localhost:5173..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Run the app
if ($flutterPath -eq "flutter") {
    flutter run -d chrome --web-port=5173
} else {
    & $flutterPath run -d chrome --web-port=5173
}

