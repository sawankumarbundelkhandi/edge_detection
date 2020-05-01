# edge_detection

A flutter plugin to detect edges of objects, scan paper, detect corner, detect rectangle. It allows cropping of the detected object image and returns the path of the cropped image.

## Usage:

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
