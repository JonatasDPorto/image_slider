# Image Slider
A Slider with images.

![Example](https://github.com/JonatasDPorto/image_slider/blob/master/readme/example.gif)

#### Use this package as a library
1. Depend on it
Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  image_slider_button: ^0.0.6
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

#### Style:

```dart
ImageSlider(
  style: ImageSliderStyleOptions(
    style: ImageSliderStyleEnum.DEFAULT,
    width: 200,
    imageWidth: 40,
    color: Colors.grey,
    borderColor: Colors.white,
  ),
  images: [
    AssetImage('assets/images/br.png'),
    AssetImage('assets/images/jp.png'),
    AssetImage('assets/images/ca.png'),
  ],
),
```
##### ImageSliderStyleEnum:
* DEFAULT
* BORDERLESS
* NODE
* NODE_BORDERLESS
* LINE
* LINE_BORDERLESS

Link to repository: [Repository](https://github.com/JonatasDPorto/image_slider)