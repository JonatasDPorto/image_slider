# Image Slider
A Slider with images.

#### Create a Image Slider:
Create a Image Slider with an array of Images.
``` js
ImageSlider(
  images: [
    AssetImage('assets/images/bra.png'),
    AssetImage('assets/images/jpn.png'),
    AssetImage('assets/images/can.png'),
  ],
),
```
#### Callbacks:
``` js
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
![Example](https://github.com/JonatasDPorto/image_slider/blob/master/readme/example.gif)

