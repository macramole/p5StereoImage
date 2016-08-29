# p5StereoImage
I'm a tool for making stereoscopic GIFs using image maps. The process is much smoother using this tool than using just Gimp or Photoshop.

![GUI](https://raw.githubusercontent.com/macramole/p5-stereo-image/master/gui.jpg)

# features
* WYSIWYG tool for making stereoscopic GIFs
* set how many frames you want, framerate and depth.
* add scanline to your gif. set width and even animate opacity.
* set how many colors and dithering algorithm 
* play around with these parameters in a realtime fashion (sort of)
* gif export

# libraries
* tested with processing 3.1.1 - http://processing.org/
* controlP5 - http://www.sojamo.de/libraries/controlP5/
* gifAnimation - https://extrapixel.github.io/gif-animation/

# how to use
1. put your image inside data/
2. put your image map inside data/
3. open sketch using processing (stereo2.pde is the main file)
4. change FILENAME_IMAGE variable to your image's filename
5. change FILENAME_MAP variable to your image map filename 
6. press play and use
7. you can change you imagemap using Gimp or any other image software and the changes will be reflected as you save. pretty neat.

# what is an image map
a grayscale image with the same size as your source image. darker gray sections will move less than lighter gray. using HSV color encoding, I recommend to go from 50% of VALUE to 100% (white).

# improvements
right now it works somehow slow. there is a lot of room for improvement
