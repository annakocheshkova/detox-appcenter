#!/usr/bin/env bash

echo "Installing android AVD..."
$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-24;google_apis;x86"
touch ~/.android/repositories.cfg

$ANDROID_HOME/tools/bin/avdmanager create avd -n Nexus_5X_API_24_-_GPlay -k "system-images;android-24;google_apis;x86" --tag "google_apis" --device "Nexus 5"
$ANDROID_HOME/tools/bin/avdmanager list avd

$ANDROID_HOME/tools/emulator -avd Nexus_5X_API_24_-_GPlay -netdelay none -netspeed full
APPLESIMUTILS_VERSION=0.5.22
echo "Installing applesimutils..."
mkdir simutils
cd simutils
curl https://raw.githubusercontent.com/wix/homebrew-brew/master/AppleSimulatorUtils-${APPLESIMUTILS_VERSION}.tar.gz -o applesimutils.tar.gz
tar xzvf applesimutils.tar.gz
sh buildForBrew.sh .
cd ..
export PATH=$PATH:./simutils/build/Build/Products/Release

echo "Installing correct node version..."
export HOMEBREW_NO_AUTO_UPDATE=1
brew uninstall node@6
brew install node@8
brew link node@8 --force --overwrite

echo "Installing dependencies for detox tests..."
npm install

if [ -z "$APPCENTER_XCODE_PROJECT" ]; then 
echo "Building the Android project for Detox tests..."
npx detox build --configuration android.emu.debug 
echo "Executing Detox tests for Android..."
#!cp package.json android/app/build/outputs/apk/debug/package.json
npx detox test -c android.emu.debug --loglevel verbose
else 
echo "Building the iOS project for Detox tests..."
npx detox build --configuration ios.sim.release;
echo "Executing Detox tests for iOS..."
npx detox test --configuration ios.sim.release --loglevel verbose --cleanup
fi
