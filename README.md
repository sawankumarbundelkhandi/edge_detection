# edge_detection

A flutter plugin to detect edges of objects, scan paper, detect corner, detect rectangle. It allows cropping of the detected object image and returns the path of the cropped image.

## Usage:

### iOS

iOS 10.0 of higher is needed to use the plugin. If compiling for any version lower than 10.0 make sure to check the iOS version before using the plugin. Change the minimum platform version to 10 (or higher) in your `ios/Podfile` file.

Add below permission to the `ios/Runner/Info.plist`:

- one with the key `Privacy - Camera Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

### Add dependency：

Please check the latest version before installation.

```
dependencies:
  flutter:
    sdk: flutter
  edge_detection: ^1.0.5
```

### Add the following imports to your Dart code:

```
import 'package:edge_detection/edge_detection.dart';
```

```dart

//Make sure to await the call to detectEdge.
String imagePath = await EdgeDetection.detectEdge;

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
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/android/4.png" width="200"/>
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
         <td style="text-align: center">
            <img src="https://raw.githubusercontent.com/sawankumarbundelkhandi/edge_detection/master/screenshots/ios/4.PNG" width="200"/>
         </td>
      </tr>
   </table>
</div>
   
Using these native implementation   
<a>https://github.com/WeTransfer/WeScan</a>

<a>https://github.com/KePeng1019/SmartPaperScan</a>
