APPLESIMUTILS_VERSION=0.5.22

#export ANDROID_SDK_HOME = /Users/vsts/.android/avd/emutest.avd/
      # Install all required sdk packages
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --update
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install tools
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install platform-tools
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install emulator
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'platforms;android-25'
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'build-tools;25.0.3'
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-28;google_apis;x86_64'
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-25;google_apis;x86_64'
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-25;google_apis;armeabi-v7a'

#echo "Installing android AVD..."
#$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-24;google_apis;x86"
#touch ~/.android/repositories.cfg

echo "Starting daemon..."
$ANDROID_HOME/platform-tools/adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill || true; done

echo "Creating AVD..."
#echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-25;google_apis;x86_64" --tag "google_apis" --device "Nexus 5" --force
echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-25;google_apis;armeabi-v7a" --force
#echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-28;google_apis;x86_64" --force



$ANDROID_HOME/tools/bin/avdmanager list avd

echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --update
echo "Starting AVD..."
nohup $ANDROID_HOME/emulator/emulator -no-window -wipe-data -qemu -enable-kvm -snapshot -no-boot-anim -noaudio -avd emutest & #> /dev/null 2>&1 &
      $ANDROID_HOME/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed | tr -d '\r') ]]; do sleep 1; done; input keyevent 82'
      
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
