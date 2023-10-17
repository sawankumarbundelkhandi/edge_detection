# edge_detection

A flutter plugin to detect edges of objects, scan paper, detect corners, detect rectangles. It allows cropping of the detected object image and returns the path of the cropped image.

## Usage:

### iOS

iOS 13.0 or higher is needed to use the plugin. If compiling for any version lower than 13.0 make sure to check the iOS version before using the plugin. Change the minimum platform version to 13 (or higher) in your `ios/Podfile` file, and inform/request access to the permissions acording with `permission_handler`

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',

        ## dart: PermissionGroup.camera
         'PERMISSION_CAMERA=1',

        ## dart: PermissionGroup.photos
         'PERMISSION_PHOTOS=1',
      ]

    end
    # End of the permission_handler configuration
  end
end
```

## Fix build on xCode 15

Add this line to your Podfile in your project:

```
pod 'WeScan', :path => '.symlinks/plugins/edge_detection/ios/WeScan-3.0.0'
```

=> like this below:

```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  pod 'WeScan', :path => '.symlinks/plugins/edge_detection/ios/WeScan-3.0.0'
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Add below permission to the `ios/Runner/Info.plist`:

- one with the key `Privacy - Camera Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Can I use the photos please?</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Can I use the photos please?</string>
```

Add to your need localizations to your app through XCode for localize actions buttons from WeScan (https://github.com/WeTransfer/WeScan/tree/master/WeScan/Resources/Localisation)

### Android

The plugin code is written in kotlin 1.8.0 so the same has to be set to the android project of yours for compilation.
Change the kotlin_version to 1.8.0 in your `android/build.gradle` file.

```
ext.kotlin_version = '1.8.0'
```

Change the minimum Android SDK version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

### Add dependency：

Please check the latest version before installation.

```
dependencies:
  flutter:
    sdk: flutter
  edge_detection: ^1.1.3
  permission_handler: ^10.0.0
  path_provider: ^2.0.11
  path: ^1.8.2
```

### Add the following imports to your Dart code:

```
import 'package:edge_detection/edge_detection.dart';
```

```dart
// Check permissions and request its
bool isCameraGranted = await Permission.camera.request().isGranted;
if (!isCameraGranted) {
    isCameraGranted = await Permission.camera.request() == PermissionStatus.granted;
}

if (!isCameraGranted) {
    // Have not permission to camera
    return;
}

// Generate filepath for saving
String imagePath = join((await getApplicationSupportDirectory()).path,
    "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

// Use below code for live camera detection with option to select from gallery in the camera feed.

try {
    //Make sure to await the call to detectEdge.
    bool success = await EdgeDetection.detectEdge(imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning', // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
    );
} catch (e) {
    print(e);
}

// Use below code for selecting directly from the gallery.

try {
    //Make sure to await the call to detectEdgeFromGallery.
    bool success = await EdgeDetection.detectEdgeFromGallery(imagePath,
        androidCropTitle: 'Crop', // use custom localizations for android
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
    );
} catch (e) {
    print(e);
}

```

## Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/demo.gif" alt="Demo" style="margin:auto" width="372" height="686">
</p>

## Screenshots

# Android

<div style="text-align: center">
   <table>
      <tr>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/android/1.png" width="200"/>
         </td>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/android/2.png" width="200" />
         </td>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/android/3.png" width="200"/>
         </td>
      </tr>
   </table>
</div>

# iOS

<div style="text-align: center">
   <table>
      <tr>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/ios/1.PNG" width="200"/>
         </td>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/ios/2.PNG" width="200" />
         </td>
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/ios/3.PNG" width="200"/>
         </td>
      </tr>
   </table>
</div>
   
Using these native implementation   
<a>https://github.com/WeTransfer/WeScan</a>

<a>https://github.com/KePeng1019/SmartPaperScan</a>
