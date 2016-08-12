//ctrl-alt-b
import controlP5.*;
import gifAnimation.*;
import java.util.Date;
import java.text.SimpleDateFormat;

ControlP5 cp5;
PImage image;
PImage map;

PImage processedImages[];
int currentImage = 0;
int currentDirection = 1;

final int DEFAULT_DEPTH = 5;
int depth = 5;
int framesQty = 3;
int gifQuality = 10;

PGraphics scanLines;
int scanLineOpacity = 76;
int scanLineWeight = 2;
boolean scanLineAnimate = false;
int scanLineMaxOpacity = 255;

boolean processingFrames = false;

int GUI_WIDTH = 100;

final String FILENAME_IMAGE = "example.jpg";
final String FILENAME_MAP = "example_map.png";
long lastModified = 0;

final String SAVE_PATH = "saved/";

ColorReduction colorReduction;
int currentDitheringAlgorithm = 1;//ColorReduction.ORDERED;

void setup() {
    
    size( 400 , 400 );
    processedImages = new PImage[framesQty];
    scanLines = createGraphics(width - GUI_WIDTH, height);

    image = loadImage(FILENAME_IMAGE);
    
    surface.setResizable(true);
    surface.setSize(image.width + GUI_WIDTH, image.height);
  
    setColorReduction(16);

    updateScanLines();
    checkForNewerMap(true);

    createGui();

    frameRate(7);
}

void createGui() {
    cp5 = new ControlP5(this);
    cp5.enableShortcuts();

    cp5.addSlider("frames")
       .setPosition(10,10)
       .setSize(80,20)
       .setRange(3,15)
       .setNumberOfTickMarks(7)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addSlider("framerate")
       .setPosition(10,55)
       .setSize(80,20)
       .setRange(1,30)
       .setValue(7)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addSlider("depth")
       .setPosition(10,100)
       .setSize(80,20)
       .setRange(1,20)
       .setValue(DEFAULT_DEPTH)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;

    cp5.addSlider("scanLineOpacity")
       .setPosition(10,160)
       .setSize(80,20)
       .setRange(0,255)
       .setValue(scanLineOpacity)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addSlider("scanLineWeight")
       .setPosition(10,205)
       .setSize(80,20)
       .setRange(2,10)
       .setValue(2)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addToggle("scanLineAnimate")
       .setPosition(10,250)
       .setSize(80,20)
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addSlider("scanLineMaxOpacity")
       .setPosition(10,295)
       .setSize(80,20)
       .setRange(100,255)
       .setValue(255)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;

    cp5.addSlider("gifQuality")
       .setPosition(10,420)
       .setSize(80,20)
       .setRange(1,20)
       .setValue(10)
       .setColorTickMark(color(0,0))
       .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
       ;
    cp5.addButton("makeGif")
       .setPosition(10,465)
       .setSize(80,20)
       ;

  

   DropdownList d = cp5.addDropdownList("dithering");
   d.setPosition(10,380);
   d.setItemHeight(20);
   d.setBarHeight(20);
   d.setWidth(GUI_WIDTH - 18);
   d.close();
   d.addItem("Floyd Steinberg", 0);
   d.addItem("Atkinson", 1);
   d.addItem("Ordered", 2);
   d.addItem("Random", 3);

 DropdownList c = cp5.addDropdownList("colors");
   c.setPosition(10,350);
   c.setItemHeight(20);
   c.setBarHeight(20);
   c.setWidth(GUI_WIDTH - 18);
   c.close();

   for ( int i = 1 ; i <= 8 ; i++ ) {
       c.addItem(str(int(pow(2,i))),pow(2,i));
   }


    fill(color(0));
}
void frames(int qty) {
  setFramesQty(qty);
}
void framerate(int f) {
    frameRate(f);
}
void depth(int qty) {
    depth = qty;
    setFramesQty( framesQty );
}
void scanLineWeight(int qty) {
    scanLineWeight = qty;
    updateScanLines();
    processFrames();
}
void scanLineOpacity(int qty) {
    scanLineOpacity = qty;
    updateScanLines();
    processFrames();
}
void scanLineAnimate(boolean wha) {
    scanLineAnimate = wha;
    if ( scanLineAnimate == false ) {
        alphaScanLines(scanLineOpacity);
    }
    processFrames();
}
void scanLineMaxOpacity(int qty) {
    scanLineMaxOpacity = qty;
    processFrames();
}
void colors(int wha) {
    setColorReduction(int(pow(2,wha + 1)));
    processFrames();
}
void dithering(int wha) {
    currentDitheringAlgorithm = wha;
    colorReduction.setDitheringAlgorithm(currentDitheringAlgorithm);
    processFrames();
}
void makeGif() {
    processingFrames = true;
    String date = (new SimpleDateFormat("yyyyMMddHHmmss")).format(new Date());

    String filename =
        SAVE_PATH +
        "stereo-f" +
        framesQty +
        "-fr" +
        round(frameRate) +
        "-d" +
        depth +
        "-t" +
        date + ".gif";

    println("making gif with quality: " + gifQuality);
    GifMaker gifExport = new GifMaker(this, filename, gifQuality);
    gifExport.setRepeat(0);

    for ( int i = 0 ; i < framesQty ; i++ ) {
        gifExport.setDelay( round(1000 / frameRate) );
        gifExport.addFrame( processedImages[i] );
    }
    for ( int i = framesQty - 2 ; i > 0 ; i-- ) {
        gifExport.setDelay( round(1000 / frameRate) );
        gifExport.addFrame( processedImages[i] );
    }

    boolean result = gifExport.finish();

    processingFrames = false;

    if ( result ) {
        println("gif done");
    } else {
        println("error making gif, sorry");
    }
}

void setColorReduction(int cantColors) {
    colorReduction = new ColorReduction(image, cantColors, currentDitheringAlgorithm);
    // colorReduction = new ColorReduction();
}

void setFramesQty(int howMuch) {
    if (howMuch >0) {
        framesQty = howMuch;
        processedImages = new PImage[framesQty];
        processFrames();
    }
}

void processFrames() {
    processingFrames = true;
    float pDepth = 0;

    int maxFirstPart = floor(framesQty / 2) - 1;
    int chunk = depth / (maxFirstPart + 1);

    for ( int i = 0 ; i <= maxFirstPart ; i++ ) {
        if ( maxFirstPart != 0 ) {
            pDepth = chunk * map(i, 0, maxFirstPart, maxFirstPart + 1, 1);
        } else {
            pDepth = chunk;
        }
        processedImages[i] = processFrame(pDepth);
        // println(i + " " + pDepth);
    }

    maxFirstPart += 1;
    processedImages[maxFirstPart] = image.copy();
    maxFirstPart += 1;

    chunk = -chunk;

    for ( int i = maxFirstPart ; i < framesQty ; i++ ) {
        if ( maxFirstPart != 2 ) {
            pDepth = chunk * map(i, maxFirstPart, framesQty - 1, 1, maxFirstPart - 1);
        } else {
            pDepth = chunk;
        }
        processedImages[i] = processFrame(pDepth);
        // println(i + " " + pDepth);
    }

    for ( int i = 0 ; i < framesQty ; i++ ) {
        // drawScanLines( processedImages[i] );
        if (scanLineAnimate) {
            alphaScanLines( round(map(i, 0, framesQty, scanLineOpacity, scanLineMaxOpacity)) );
        }
        processedImages[i].blend( scanLines, 0, 0, processedImages[i].width, processedImages[i].height, 0, 0, processedImages[i].width, processedImages[i].height, OVERLAY );
        processedImages[i] = colorReduction.reduceColors(processedImages[i]);
    }

    processingFrames = false;
}

void checkForNewerMap() {
    checkForNewerMap(false);
}
void checkForNewerMap(boolean noDelay) {
    String path = sketchPath("data/" + FILENAME_MAP);
    File file = new File(path);
    long newLastModified = file.lastModified();

    if ( lastModified != newLastModified ) {
        lastModified = newLastModified;
        processingFrames = true;
        if (!noDelay) {
            delay(3000);
        }
        map = loadImage(FILENAME_MAP);
        processFrames();
    }
}

void draw() {

    rect(0, 0, GUI_WIDTH, height);
    if ( !processingFrames ) {

        try {
            image(processedImages[currentImage], GUI_WIDTH + 1, 0);
        } catch ( Exception e ) {
            println(e);
        }

        if ( currentImage == framesQty - 1 ) {
            currentDirection = -1;
        } else if ( currentImage == 0 ) {
            currentDirection = 1;
            checkForNewerMap();
        }

        currentImage += 1 * currentDirection;
    }
}

void updateScanLines() {
    scanLines.beginDraw();
    scanLines.strokeWeight(scanLineWeight);
    scanLines.strokeCap(SQUARE);
    scanLines.stroke(0, scanLineOpacity);
    scanLines.background(0,0);

    for ( int y = 0 ; y <= height ; y += scanLineWeight + 1 ) {
        scanLines.line(0,y,width - GUI_WIDTH,y);
    }
    scanLines.endDraw();
}
void updateScanLines(int forceOpacity) {
    scanLines.beginDraw();
    scanLines.strokeWeight(scanLineWeight);
    scanLines.strokeCap(SQUARE);
    scanLines.stroke(0, forceOpacity);
    scanLines.background(0,0);

    for ( int y = 0 ; y <= height ; y += scanLineWeight + 1 ) {
        scanLines.line(0,y,width - GUI_WIDTH,y);
    }
    scanLines.endDraw();
}
void alphaScanLines(int alpha) {
    updateScanLines(alpha);
}

PImage processFrame(float depth) {
    PImage frame = image.copy();
    frame.loadPixels();

    if ( depth > 0 ) {
        for ( int y = 0 ; y < image.height ; y++ ) {
            for ( int x = 0 ; x < image.width ; x++ ) {
                color imagePixel = image.pixels[y*image.width+x];
                color mapPixel = map.pixels[y*map.width+x];
                float brightnessMap = brightness( mapPixel );

                if ( mapPixel != color(0,0,0,0) ) {
                    float displacement = 0;
                    int targetX = 0;

                    displacement = depth * ( (brightnessMap - 127.5) / 127.5 );
                    int extraDisplacement = 0;
                    // int targetXInterpolation = 0;

                    if ( displacement > 0 ) {
                        targetX = x - floor(displacement);
                        extraDisplacement = x + floor(displacement);
                        // extraDisplacement = displacement - floor(displacement);
                        // targetXInterpolation = targetX - 1;
                    } else {
                        targetX = x - ceil(displacement);
                        extraDisplacement = x + ceil(displacement);
                        // extraDisplacement = displacement - ceil(displacement);
                        // targetXInterpolation = targetX + 1;
                    }

                    if ( targetX > 0 && targetX < image.width ) {
                        frame.set(targetX,y,imagePixel);
                        if (extraDisplacement > 0 && extraDisplacement < image.width ) {
                            color extraPixel = frame.get(extraDisplacement, y);
                            frame.set(x,y,extraPixel);
                        }
                    }
                }
            }
        }
    } else {
        for ( int y = image.height - 1 ; y >= 0 ; y-- ) {
            for ( int x = image.width - 1 ; x >= 0 ; x-- ) {
                color imagePixel = image.pixels[y*image.width+x];
                color mapPixel = map.pixels[y*map.width+x];
                float brightnessMap = brightness( mapPixel );

                if ( mapPixel != color(0,0,0,0) ) {
                    float displacement = 0;
                    int targetX = 0;

                    displacement = depth * ( (brightnessMap - 127.5) / 127.5 );
                    int extraDisplacement = 0;
                    // int targetXInterpolation = 0;

                    if ( displacement > 0 ) {
                        targetX = x - floor(displacement);
                        extraDisplacement = x + floor(displacement);
                        // extraDisplacement = displacement - floor(displacement);
                        // targetXInterpolation = targetX - 1;
                    } else {
                        targetX = x - ceil(displacement);
                        extraDisplacement = x + ceil(displacement);
                        // extraDisplacement = displacement - ceil(displacement);
                        // targetXInterpolation = targetX + 1;
                    }

                    if ( targetX > 0 && targetX < image.width ) {
                        frame.set(targetX,y,imagePixel);
                        if (extraDisplacement > 0 && extraDisplacement < image.width ) {
                            color extraPixel = frame.get(extraDisplacement, y);
                            frame.set(x,y,extraPixel);
                        }
                    }

                    // if ( extraDisplacement > 0 ) {
                    //     // println(extraDisplacement);
                    //     int alpha = round(map(extraDisplacement, 0, 1, 0, 255));
                    //     // println(alpha);
                    //     color interpolationPixel = color(
                    //         red(imagePixel),
                    //         green(imagePixel),
                    //         blue(imagePixel),
                    //         alpha
                    //         );
                    //
                    //     // color currentPixel = frame.get(targetXInterpolation, y);
                    //     frame.set(targetXInterpolation, y, interpolationPixel); //+ currentPixel);
                    // }
                }
            }
        }
    }

    frame.updatePixels();
    return frame;
}



void keyPressed() {
    // addFramesQty(2);
}