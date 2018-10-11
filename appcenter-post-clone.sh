#!/usr/bin/env bash
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
npx detox build --configuration android.emu.release 
echo "Executing Detox tests for Android..."
npx detox test --configuration android.emu.release --cleanup
else 
echo "Building the iOS project for Detox tests..."
npx detox build --configuration ios.sim.release;
echo "Executing Detox tests for iOS..."
npx detox test --configuration ios.sim.release --cleanup
fi

//echo "Supported devices:"
//adb device list
//xcrun simctl list
