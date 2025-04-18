# Toilet Earner App

A Flutter application that calculates how much money you earn while in the toilet during office hours.

## Features

- Calculate earnings based on your monthly salary
- Track toilet time with start/stop functionality
- View history of toilet sessions with date, time, duration, and earnings
- Authentication with Google (all platforms) and Apple (iOS only)
- Secure storage of session data in Firebase Firestore
- Summary of total time spent and money earned

## Setup

### Prerequisites

- Flutter SDK
- Firebase account
- iOS development setup (for Apple Sign-In)

### Firebase Setup

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Google and Apple providers
3. Enable Firestore Database
4. Add your Flutter app to the Firebase project:
   ```
   flutterfire configure
   ```

### Configuration

1. Update the `firebase_options.dart` file with your Firebase credentials
2. For iOS, update the iOS app configuration for Apple Sign-In

### Dependencies

Run the following command to install all required dependencies:

```
flutter pub get
```

## Development

To run the app in development mode:

```
flutter run
```

## Build and Release

To build a release version for Android:

```
flutter build apk
```

To build a release version for iOS:

```
flutter build ios
```

## Project Structure

- `lib/models` - Data models
- `lib/providers` - State management providers
- `lib/screens` - UI screens
- `lib/firebase_options.dart` - Firebase configuration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
