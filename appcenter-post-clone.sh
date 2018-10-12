#If an iOS app in AppCenter (APPCENTER_XCODE_PROJECT is AC env var)
if [ -n "$APPCENTER_XCODE_PROJECT" ]; then
      APPLESIMUTILS_VERSION=0.5.22    
      echo "Installing applesimutils..."
      mkdir simutils
      cd simutils
      curl https://raw.githubusercontent.com/wix/homebrew-brew/master/AppleSimulatorUtils-${APPLESIMUTILS_VERSION}.tar.gz -o applesimutils.tar.gz
      tar xzvf applesimutils.tar.gz
      sh buildForBrew.sh .
      cd ..
      export PATH=$PATH:./simutils/build/Build/Products/Release
fi

echo "Installing correct node version..."
export HOMEBREW_NO_AUTO_UPDATE=1
brew uninstall node@6
brew install node@8
brew link node@8 --force --overwrite

echo "Installing dependencies for detox tests..."
npm install

if [ -n "$APPCENTER_XCODE_PROJECT" ]; then 
      echo "Building the iOS project for Detox tests..."
      npx detox build --configuration ios.sim.release;
      echo "Executing Detox tests for iOS..."
      npx detox test --configuration ios.sim.release --loglevel verbose --cleanup
else
      #echo "Installing android system image..."
      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --update
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install tools
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install platform-tools
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install emulator
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'platforms;android-27'
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'build-tools;27.0.3'

      #!! Run sdkmanager --list to see what's installed/available
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-27;google_apis;x86'

      echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-21;google_apis;x86_64'
      #the problem may be in google-apis image, default one may be useful.
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-25;default;x86_64'

      #armeabi can be run w\o -no-accel flag
      #echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --install 'system-images;android-25;google_apis;armeabi-v7a'

      echo "Starting daemon..."
      $ANDROID_HOME/platform-tools/adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill || true; done

      echo "Creating AVD..."
      echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-21;google_apis;x86_64" --device "Nexus 5" --force
      #echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-27;google_apis;x86" --device "Nexus 5" --force
      #echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-25;default;x86_64" --device "Nexus 5" --force
      #echo "no" | $ANDROID_HOME/tools/bin/avdmanager create avd -n emutest -k "system-images;android-25;google_apis;armeabi-v7a" --force

      #do not delete
      $ANDROID_HOME/tools/bin/avdmanager list avd

      echo "Starting AVD..."
      #some flags to play with: -qemu -no-window -enable-kvm -no-boot-anim  -no-snapshot -noaudio
      #https://stackoverflow.com/questions/47748948/android-emulator-never-finishes-booting-when-no-window-flag-is-used
      
      nohup $ANDROID_HOME/emulator/emulator -avd emutest -gpu on  -no-accel  -no-boot-anim -partition-size 2048 -wipe-data -skin "1080x1920" & #> /dev/null 2>&1 & (uncomment to hide output)
      #comment line after shell to start emulator async
      $ANDROID_HOME/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82' 
      
      echo "Building the Android project for Detox tests..."
      npx detox build --configuration android.emu.debug 
      echo "Executing Detox tests for Android..."
      npx detox test -c android.emu.debug --loglevel verbose  
fi
