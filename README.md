# Image Slider
A Slider with images.

![Brazil](https://github.com/JonatasDPorto/image_slider/blob/master/readme/1.PNG)
![Japan](https://github.com/JonatasDPorto/image_slider/blob/master/readme/2.png)
![Canada](https://github.com/JonatasDPorto/image_slider/blob/master/readme/3.png)

#### Use this package as a library
1. Depend on it
Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  image_slider_button: ^0.0.1
```
2. Install it
You can install packages from the command line:

with pub:
```
$ pub get
```
with Flutter:
```
$ flutter pub get
```
Alternatively, your editor might support pub get or flutter pub get. Check the docs for your editor to learn more.

3. Import it
Now in your Dart code, you can use:
```dart
import 'package:image_slider_button/image_slider.dart';
import 'package:image_slider_button/image_slider_painter.dart';
```
#### Create a Image Slider:
Create a Image Slider with an array of Images.
``` dart
ImageSlider(
  images: [
    AssetImage('assets/images/bra.png'),
    AssetImage('assets/images/jpn.png'),
    AssetImage('assets/images/can.png'),
  ],
),
```
#### Callbacks:
``` dart
ImageSlider(
  images: [
    AssetImage('assets/images/bra.png'),
    AssetImage('assets/images/jpn.png'),
    AssetImage('assets/images/can.png'),
  ],
  onStart: () {
    // DO STUFF
  },
  onUpdate: (percentage) {
    // DO STUFF
    print(percentage);
  },
  onEnd: (position) {
    // DO STUFF
    print(pos);
  },
),
```
<<<<<<< HEAD
![Example](https://github.com/JonatasDPorto/image_slider/blob/master/readme/example.gif)
=======
>>>>>>> bdabe21aab3957b1cd25a55296502683ff8dccaa

