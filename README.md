# Cobonno

## Getting Started

1. Clone this repository
2. Run `flutter pub get`
3. For ios, go to ios folder then run
```sh
# for mac intel
$ pod install
# for mac silicon
$ arch -x86_64 pod install
```
4. Run configuration selector
```sh
# on mac/linux, just run from terminal
# on windows, run from git-bash terminal
## for development
$ bash ./config/go-development.sh
## for production
$ bash ./config/go-production.sh
```

_\*Cobonno works on iOS and Android._

## To Generate new icons

```sh
$ flutter pub run flutter_launcher_icons:main
```

## Firebase Project

1. Development: https://console.firebase.google.com/project/cobonno-museum
2. Production: https://console.firebase.google.com/project/cobonno-prod

## Bundle IDs

This are based on the app deployed to AppStore and PlayStore.

1. Development

**iOS**
Bundle: com.ardgets.cobonno.dev
Link: https://appstoreconnect.apple.com/apps/1639617795/appstore/info

**Android**
Bundle: -
Link: -

2. Production

**iOS**
Bundle: com.cobonno
Link: https://appstoreconnect.apple.com/apps/1634871320/appstore/info

**Android**
Bundle: com.cobonno.app
Link: https://play.google.com/console/u/0/developers/6699928395317140855/app/4975768134075543071/app-dashboard
