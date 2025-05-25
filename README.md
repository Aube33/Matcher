<img src="img/icon.png" width=128 style="border-radius: 20px; margin-right: 20px;">

# Matcher, Open source dating app
Open source dating app in Flutter, with API based on ExpressJS and PostgreSQL.

## <u>Requirements</u>
- [Flutter](https://flutter.dev/)
- [Android Studio, not APPLE](https://developer.android.com/studio)
- [Docker](https://www.docker.com/)

## <u>API Setup</u>
### Firebase Cloud Messaging:
Follow firsts steps of this [tutorial](https://medium.com/@jonatanramhoj/firebase-admin-sdk-installation-guide-f64349d86a9d) and once you have your private key json file, place it in `matcher_api/firebase/` directory.
<hr>

### SendGrid:
You need a [SendGrid API KEY](https://sendgrid.com/en-us/solutions/email-api) to send email on registration, lost password and account deletion.
Once you have your API KEY go to `.env_api` and change this line with your key:
```
SENDGRID_API_KEY = xxx
```
<hr>

### Start the API
Start backend containers:
```
docker compose up -d
```

<br>
<br>

## <u>App Setup</u>
### Firebase:
Add Firebase to `matcher_app` flutter project with your Firebase account.

[Tutorial](https://firebase.google.com/docs/flutter/setup?platform=ios)

Register a new Android app on your Firebase project, and download the configuration file from the Firebase Console (the file is called google-services.json). Add this file into the `matcher_app/android/app/` directory.

[Tutorial](https://firebase.flutter.dev/docs/manual-installation/android/#generating-a-firebase-project-configuration-file)
<hr>

### API:
Go to `matcher_app/lib/configs/api.configs.dart` and change `API_URL` with your local IP and API port.

Example:
```dart
const String API_URL = "http://192.168.1.140:3000/api";
```

### Start the App:
Run `matcher_app` on Android Virtual Device (AVD)

[Tutorial](https://dev.to/derva/flutter-android-virtual-device-avd-run-in-8-steps-32e7)


## <u>Demo</u>:
[![Youtube Matcher Demo](http://img.youtube.com/vi/m9TuktSo_xY/0.jpg)](http://www.youtube.com/watch?v=m9TuktSo_xY "Matcher Demo")
