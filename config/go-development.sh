#!/bin/bash
cp config/development_android__AndroidManifest.xml android/app/src/main/AndroidManifest.xml
cp config/development_android__google-services.json android/app/google-services.json
cp config/development_android__strings.xml android/app/src/main/res/values/strings.xml
cp config/development_ios__firebase_app_id_file.json ios/firebase_app_id_file.json
cp config/development_ios__Info.plist ios/Runner/Info.plist
cp config/development_ios__GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
cp config/development_lib__firebase_options.dart lib/firebase_options.dart