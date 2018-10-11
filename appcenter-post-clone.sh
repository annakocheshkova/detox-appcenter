#!/usr/bin/env bash

$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-24;google_apis;x86"
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
echo "Installing android AVD..."
$ANDROID_HOME/sdk/tools/bin/sdkmanager "system-images;android-24;google_apis;x86"



touch ~/.android/repositories.cfg

/Users/vsts/Library/Android/sdk/tools/bin/avdmanager create avd -n Nexus_5X_API_24_-_GPlay -k "system-images;android-24;google_apis;x86" --tag "google_apis" --device "Nexus 5"
/Users/vsts/Library/Android/sdk/tools/bin/avdmanager list avd
echo "Building the Android project for Detox tests..."
npx detox build --configuration android.emu.debug 
echo "Executing Detox tests for Android..."
cp package.json android/app/build/outputs/apk/debug/package.json
/Users/vsts/Library/Android/sdk/tools/emulator @Nexus_5X_API_24_-_GPlay -port 49821
npx detox test -c android.emu.debug --loglevel verbose
else 
echo "Building the iOS project for Detox tests..."
npx detox build --configuration ios.sim.release;
echo "Executing Detox tests for iOS..."
npx detox test --configuration ios.sim.release --loglevel verbose --cleanup
fi

#!echo "Supported devices:"
#!adb device list
#!xcrun simctl list
