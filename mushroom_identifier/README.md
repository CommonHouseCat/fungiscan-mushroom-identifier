## Installing the App on a Physical Device (via USB with ADB)

1. On your Android device, enable **Developer Options**.
2. Enable **USB Debugging** in Developer Options.
3. Connect your phone to your computer via USB and allow USB debugging when prompted.

Then run one of the following commands in your terminal:
```sh
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

If installing over an older version of the app (recommended flag):
```sh
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```