// great part of the code is based on https://github.com/dpiccone/dithering_algorithms/
class Dithering {
 	PImage doFloydSteinberg(PImage src, color[] palette) {
		// Define step
	    int s = 1;
		PImage result = new PImage(src.width, src.height);
		PImage srcCopy = src.copy();
		srcCopy.loadPixels();
		result.loadPixels();
	    // Scan image
	    for (int x = 0; x < srcCopy.width; x+=s) {
	      for (int y = 0; y < srcCopy.height; y+=s) {
	        color oldpixel = srcCopy.get(x, y);
	        color newpixel = findClosestColor(oldpixel, palette);
	        color quant_error = color(red(oldpixel) - red(newpixel), green(oldpixel) - green(newpixel), blue(oldpixel) - blue(newpixel));
	        srcCopy.set(x, y, newpixel);

			color s1 = srcCopy.get(x+s, y);
			srcCopy.set(x+s, y, color( red(s1) + 7.0/16 * red(quant_error), green(s1) + 7.0/16 * green(quant_error), blue(s1) + 7.0/16 * blue(quant_error) ));
			color s2 = srcCopy.get(x-s, y+s);
			srcCopy.set(x-s, y+s, color( red(s2) + 3.0/16 * red(quant_error), green(s2) + 3.0/16 * green(quant_error), blue(s2) + 3.0/16 * blue(quant_error) ));
			color s3 = srcCopy.get(x, y+s);
			srcCopy.set(x, y+s, color( red(s3) + 5.0/16 * red(quant_error), green(s3) + 5.0/16 * green(quant_error), blue(s3) + 5.0/16 * blue(quant_error) ));
			color s4 = srcCopy.get(x+s, y+s);
			srcCopy.set(x+s, y+s, color( red(s4) + 1.0/16 * red(quant_error), green(s4) + 1.0/16 * green(quant_error), blue(s4) + 1.0/16 * blue(quant_error) ));

			result.set(x, y, newpixel);

	      }
	    }
		result.updatePixels();
		return result;
	}

	PImage doOrdered(PImage src, color[] palette) {
		// Bayer matrix
		int[][] matrix = {
		  {
		    1, 9, 3, 11
		  }
		  ,
		  {
		    13, 5, 15, 7
		  }
		  ,
		  {
		    4, 12, 2, 10
		  }
		  ,
		  {
		    16, 8, 14, 6
		  }
		};

		float mratio = 1.0 / 17;
		float mfactor = 255.0 / 5;

		// Define step
	    int s = 1;

		PImage result = new PImage(src.width, src.height);
		PImage srcCopy = src.copy();
		srcCopy.loadPixels();
		result.loadPixels();

		// Scan image
	    for (int x = 0; x < srcCopy.width; x+=s) {
	      for (int y = 0; y < srcCopy.height; y+=s) {
	        // Calculate pixel
	        color oldpixel = srcCopy.get(x, y);
	        color value = color( (oldpixel >> 16 & 0xFF) + (mratio*matrix[x%4][y%4] * mfactor), (oldpixel >> 8 & 0xFF) + (mratio*matrix[x%4][y%4] * mfactor), (oldpixel & 0xFF) + + (mratio*matrix[x%4][y%4] * mfactor) );
	        color newpixel = findClosestColor(value, palette);
	        // srcCopy.set(x, y, newpixel);
	        // Draw
	        // stroke(newpixel);
	        //point(x, y);
	        // line(x,y,x+s,y+s);
			result.set(x,y,newpixel);
	      }
	    }

		result.updatePixels();
		return result;
	}

	PImage doAtkinson(PImage src, color[] palette) {
		// Define step
	    int s = 1;
		PImage result = new PImage(src.width, src.height);
		PImage srcCopy = src.copy();
		srcCopy.loadPixels();
		result.loadPixels();

	    // Scan image
	    for (int x = 0; x < srcCopy.width; x+=s) {
	      for (int y = 0; y < srcCopy.height; y+=s) {
	        // Calculate pixel
	        color oldpixel = srcCopy.get(x, y);
	        color newpixel = findClosestColor(oldpixel, palette);
	        color quant_error = color(red(oldpixel) - red(newpixel), green(oldpixel) - green(newpixel), blue(oldpixel) - blue(newpixel));
	        srcCopy.set(x, y, newpixel);

	        // Atkinson algorithm http://verlagmartinkoch.at/software/dither/index.html
	        color s1 = srcCopy.get(x+s, y);
	        srcCopy.set(x+s, y, color( red(s1) + 1.0/8 * red(quant_error), green(s1) + 1.0/8 * green(quant_error), blue(s1) + 1.0/8 * blue(quant_error) ));
	        color s2 = srcCopy.get(x-s, y+s);
	        srcCopy.set(x-s, y+s, color( red(s2) + 1.0/8 * red(quant_error), green(s2) + 1.0/8 * green(quant_error), blue(s2) + 1.0/8 * blue(quant_error) ));
	        color s3 = srcCopy.get(x, y+s);
	        srcCopy.set(x, y+s, color( red(s3) + 1.0/8 * red(quant_error), green(s3) + 1.0/8 * green(quant_error), blue(s3) + 1.0/8 * blue(quant_error) ));
	        color s4 = srcCopy.get(x+s, y+s);
	        srcCopy.set(x+s, y+s, color( red(s4) + 1.0/8 * red(quant_error), green(s4) + 1.0/8 * green(quant_error), blue(s4) + 1.0/8 * blue(quant_error) ));
	        color s5 = srcCopy.get(x+2*s, y);
	        srcCopy.set(x+2*s, y, color( red(s5) + 1.0/8 * red(quant_error), green(s5) + 1.0/8 * green(quant_error), blue(s5) + 1.0/8 * blue(quant_error) ));
	        color s6 = srcCopy.get(x, y+2*s);
	        srcCopy.set(x, y+2*s, color( red(s6) + 1.0/8 * red(quant_error), green(s6) + 1.0/8 * green(quant_error), blue(s6) + 1.0/8 * blue(quant_error) ));

	        result.set(x,y,newpixel);

	      }
	    }

		return result;
	}

	PImage doRandom(PImage src, color[] palette) {
		int s = 1;
		PImage result = new PImage(src.width, src.height);
		PImage srcCopy = src.copy();
		srcCopy.loadPixels();
		result.loadPixels();

		for (int x = 0; x < srcCopy.width; x+=s) {
			for (int y = 0; y < srcCopy.height; y+=s) {
				color oldpixel = srcCopy.get(x, y);
				color newpixel = findClosestColor( color ( red(oldpixel) + random(-64,64),green(oldpixel) + random(-64,64),blue(oldpixel) + random(-64,64) ), palette );

				result.set(x,y,newpixel);
			}
		}

		return result;
	}

	private color findClosestColor(color in, color[] palette) {
	  PVector[] vpalette = new PVector[palette.length];
	//   PVector vcolor = new PVector( (in >> 16 & 0xFF), (in >> 8 & 0xFF), (in & 0xFF));
	  PVector vcolor = new PVector( red(in), green(in), blue(in) );
	  int current = 0;
	  float distance = vcolor.dist(new PVector(red(palette[0]), green(palette[0]), blue(palette[0])));

	  for (int i=1; i<palette.length; i++) {
	    // // Using bit shifting in for loop is faster
	    // int r = (palette[i] >> 16 & 0xFF);
	    // int g = (palette[i] >> 8 & 0xFF);
	    // int b = (palette[i] & 0xFF);
	    // vpalette[i] = new PVector(r, g, b);
	    vpalette[i] = new PVector(red(palette[i]), green(palette[i]), blue(palette[i]));
	    float d = vcolor.dist(vpalette[i]);
	    if (d < distance) {
	      distance = d;
	      current = i;
	    }
	  }
	  return palette[current];
	}
}
