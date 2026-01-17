# AI Car Intake - Smart Vehicle Analysis Platform

A Flutter-based Progressive Web App (PWA) designed for small pre-owned car dealers to manage their inventory using AI-powered vehicle analysis.

## Features

- 🔐 **Authentication System** - Default credentials: admin / admin123
- 🌐 **Bilingual Support** - Tamil and English language toggle
- 📊 **Dashboard** - Overview of car inventory with key metrics
- 🤖 **AI Car Analysis** - Upload car photos for comprehensive AI analysis
- 📦 **Inventory Management** - View and manage all cars in inventory
- 📋 **Car Details** - Detailed view with sustainability metrics
- 🌱 **Sustainability Features** - Carbon footprint, green rating, and sustainability scores
- 📱 **PWA Ready** - Works seamlessly on mobile, web, and all channels

## Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Routing**: GoRouter
- **AI Integration**: Google Gemini (Vertex AI)
- **Storage**: SharedPreferences
- **File Handling**: File Picker

## Setup Instructions

### Prerequisites

1. Flutter SDK (3.0.0 or higher)
2. Dart SDK
3. Web browser (Chrome recommended for development)

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd AIpoweredcarintakeflutter
   ```

2. **Get Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on web (localhost)**
   ```bash
   flutter run -d chrome --web-port=5173
   ```

   Or use:
   ```bash
   flutter run -d web-server --web-port=5173
   ```

### Default Credentials

- **Username**: admin
- **Password**: admin123

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── car_model.dart        # Car data model
├── providers/
│   ├── auth_provider.dart     # Authentication state
│   ├── language_provider.dart # Language toggle state
│   └── car_provider.dart      # Car inventory state
├── screens/
│   ├── login_screen.dart      # Login page
│   ├── dashboard_screen.dart   # Dashboard with metrics
│   ├── analyze_car_screen.dart # Car analysis upload
│   ├── inventory_screen.dart   # Car inventory grid
│   └── car_details_screen.dart # Individual car details
├── services/
│   └── ai_service.dart        # AI/Gemini integration
├── utils/
│   └── app_router.dart       # Navigation routing
└── widgets/
    ├── app_header.dart        # Common header
    └── language_toggle.dart   # Language switcher
```

## Key Features Implementation

### Authentication
- Simple username/password authentication
- Session persistence using SharedPreferences
- Default credentials for easy access

### Language Support
- Tamil and English bilingual interface
- Language preference saved locally
- All UI text translated

### AI Integration
- Google Gemini API integration for car analysis
- Analyzes uploaded car images
- Extracts: make, model, year, condition, damages, odometer, etc.
- Generates sustainability metrics

### Sustainability Features
- Sustainability Score (0-100)
- Carbon Footprint calculation
- Green Rating (A, B, C, D)
- Average sustainability tracking

## Development

### Running in Development Mode

```bash
flutter run -d chrome --web-port=5173
```

The app will be available at `http://localhost:5173`

### Building for Production

```bash
flutter build web
```

Output will be in `build/web/` directory.

## API Configuration

The app uses Google Gemini API for AI analysis. The API key is configured in `lib/services/ai_service.dart`.

**Note**: In production, store API keys securely and never commit them to version control.

## Browser Support

- Chrome (Recommended)
- Firefox
- Edge
- Safari

## Responsive Design

The app is designed to work on:
- Desktop browsers
- Tablets
- Mobile devices
- PWA installation

## Security Features

- Input validation
- Secure authentication
- Data validation for car analysis
- Error handling with user-friendly messages

## Future Enhancements

- Image upload to cloud storage
- Real-time AI analysis with image processing
- Advanced filtering and search
- Export functionality
- Print reports
- Multi-user support

## License

This project is proprietary software.

## Support

For issues or questions, please contact the development team.

