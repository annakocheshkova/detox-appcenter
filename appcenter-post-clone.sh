#!/usr/bin/env bash
APPLESIMUTILS_VERSION=0.5.22
cd /Users/vsts/Library/Android/sdk/tools/bin
avdmanager list avd
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

emulator -list-avds
npx detox build --configuration android.emu.debug 
echo "Executing Detox tests for Android..."
cp package.json android/app/build/outputs/apk/debug/package.json
npx detox test -c android.emu.debug
else 
echo "Building the iOS project for Detox tests..."
npx detox build --configuration ios.sim.release;
echo "Executing Detox tests for iOS..."
npx detox test --configuration ios.sim.release --loglevel verbose --cleanup
fi

#!echo "Supported devices:"
#!adb device list
#!xcrun simctl list
