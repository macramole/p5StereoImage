# p5-stereo-image
* tested with processing 3.1.1

# libraries
* controlP5 - http://www.sojamo.de/libraries/controlP5/
* gifAnimation - https://extrapixel.github.io/gif-animation/

# how to use
1. put your image inside data/
2. put your image map inside data/
3. open sketch using processing stereo2.pde
4. change FILENAME_IMAGE variable to your image's filename
5. change FILENAME_MAP variable to your image map filename 
6. change size() to your image's size + GUI_WIDTH
7. press play and use

# what is a map
an image from the same size as your source image painted in gray. using hsv, 50% of v is no movement. 100% of v (white) is full movement.

# improvements
right now it works quite slow. there is a lot of room for improvement
