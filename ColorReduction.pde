class ColorReduction {

	color[] palette = null;

	final int RED = 0;
	final int GREEN = 1;
	final int BLUE = 2;

	final int NONE = -1;
	final int FLOYD_STEINBERG = 0;
	final int ATKINSON = 1;
	final int ORDERED = 2;
	final int RANDOM = 3;

	int ditheringAlgorithm = FLOYD_STEINBERG;

	ColorReduction() {
		populateDefaultPalette();
	}
	ColorReduction(PImage src, int cantColors) {
		processOptimizedPalette(src, cantColors);
	}
	ColorReduction(PImage src, int cantColors, int ditheringAlgorithm) {
		setDitheringAlgorithm(ditheringAlgorithm);
		processOptimizedPalette(src, cantColors);
	}

	void setDitheringAlgorithm(int d) {
		ditheringAlgorithm = d;
	}

	PImage reduceColors(PImage src) {
		Dithering d = new Dithering();

		switch( ditheringAlgorithm ) {
			case FLOYD_STEINBERG:
				return d.doFloydSteinberg(src, palette);
			case ORDERED:
				return d.doOrdered(src, palette);
			case ATKINSON:
				return d.doAtkinson(src, palette);
			case RANDOM:
				return d.doRandom(src, palette);
		}
		return null;
	}

	//median cut based on https://en.wikipedia.org/wiki/Median_cut
	void processOptimizedPalette(PImage src, int cantColors) {
		int cantSteps = int(log(cantColors) / log(2));
		palette = new color[cantColors];
		Integer[][] medianCutLastResult = null;
		Integer[][] medianCutResult = null;

		src.loadPixels();
		medianCutResult = medianCutLastResult = doMedianCut(src.pixels);
		for ( int i = 2 ; i <= cantSteps ; i++ ) {
			medianCutResult = new Integer[int(pow(2,i))][];

			for ( int j = 0 ; j < medianCutLastResult.length ; j++ ) {
				Integer[][] median = doMedianCut( medianCutLastResult[j] );
				medianCutResult[ j * 2 ] = median[0];
				medianCutResult[ j * 2 + 1 ] = median[1];
			}

			medianCutLastResult = medianCutResult;
		}

		// println("Colors:");
		for ( int i = 0 ; i < cantColors ; i++ ) {
			palette[i] = getAverageColor(medianCutResult[i]);
			// println("(" + red(palette[i]) + "," + green(palette[i]) + "," + blue(palette[i]) + ")");
		}
	}
	private Integer[][] doMedianCut(Integer[] pixelArray) {
		int highestColorRange = getChannelHighestRange(pixelArray);

		// switch ( highestColorRange ) {
		// 	case RED:
		// 		println("RED WINS");
		// 		break;
		// 	case BLUE:
		// 		println("BLUE WINS");
		// 		break;
		// 	case GREEN:
		// 		println("GREEN WINS");
		// 		break;
		// }

		Integer[] sortedPixels = sortPixelsByChannel( pixelArray, highestColorRange );
		Integer[][] medianCutResult = {
			java.util.Arrays.copyOfRange(sortedPixels, 0, floor(sortedPixels.length / 2) - 1 ),
			java.util.Arrays.copyOfRange(sortedPixels, floor(sortedPixels.length / 2), sortedPixels.length - 1 )
		};

		// println( medianCutResult[0].length + " & " + medianCutResult[1].length );

		return medianCutResult;
	}
	private Integer[][] doMedianCut(color[] pixelArray) {
		Integer[] integerPixelData = new Integer[pixelArray.length];
		for ( int i = 0 ; i < pixelArray.length ; i++ ) {
			integerPixelData[i] = Integer.valueOf(pixelArray[i]);
		}
		return doMedianCut(integerPixelData);
	}
	private int getChannelHighestRange(Integer[] pixelArray) {
		float[] redRange = {255,0}; //[min, max]
		float[] greenRange = {255,0};
		float[] blueRange = {255,0};

		for ( int i = 0 ; i < pixelArray.length ; i++ ) {
			float r = red(pixelArray[i]);
			float g = green(pixelArray[i]);
			float b = blue(pixelArray[i]);

			if ( r < redRange[0] ) {
				redRange[0] = r;
			}
			if ( r > redRange[1] ) {
				redRange[1] = r;
			}

			if ( g < greenRange[0] ) {
				greenRange[0] = g;
			}
			if ( g > greenRange[1] ) {
				greenRange[1] = g;
			}

			if ( b < blueRange[0] ) {
				blueRange[0] = b;
			}
			if ( b > blueRange[1] ) {
				blueRange[1] = b;
			}
		}

		int redFinalRange = (int)(redRange[1] - redRange[0]);
		int greenFinalRange = (int)(greenRange[1] - greenRange[0]);
		int blueFinalRange = (int)(blueRange[1] - blueRange[0]);

		int maxRange = max(redFinalRange, greenFinalRange, blueFinalRange);
		if ( maxRange == redFinalRange ) {
			return RED;
		} else if ( maxRange == greenFinalRange ) {
			return GREEN;
		} else if ( maxRange == blueFinalRange ) {
			return BLUE;
		} else {
			println("getChannelHighestRange failed");
			return RED;
		}
	}
	private Integer[] sortPixelsByChannel(Integer[] pixelArray, int channel) {
		Integer[] integerPixelData = new Integer[pixelArray.length];
		for ( int i = 0 ; i < pixelArray.length ; i++ ) {
			integerPixelData[i] = Integer.valueOf(pixelArray[i]);
		}

		if ( channel == RED ) {
			java.util.Arrays.sort( integerPixelData , new java.util.Comparator<Integer>() {
				public int compare(Integer a, Integer b) {
				  return (red(a) < red(b) ? -1 : (red(a) == red(b) ? 0 : 1));
				}
			} );
		}
		if ( channel == GREEN ) {
			java.util.Arrays.sort( integerPixelData , new java.util.Comparator<Integer>() {
				public int compare(Integer a, Integer b) {
				  return (green(a) < green(b) ? -1 : (green(a) == green(b) ? 0 : 1));
				}
			} );
		}
		if ( channel == BLUE ) {
			java.util.Arrays.sort( integerPixelData , new java.util.Comparator<Integer>() {
				public int compare(Integer a, Integer b) {
				  return (blue(a) < blue(b) ? -1 : (blue(a) == blue(b) ? 0 : 1));
				}
			} );
		}

		return integerPixelData;
	}
	private color getAverageColor(Integer[] pixelArray) {
		int red = 0;
		int green = 0;
		int blue = 0;

		for ( int i = 0 ; i < pixelArray.length ; i++ ) {
			red += red(pixelArray[i]);
			green += green(pixelArray[i]);
			blue += blue(pixelArray[i]);
		}

		red /= pixelArray.length;
		green /= pixelArray.length;
		blue /= pixelArray.length;

		return color(red, green, blue);
	}

	private void populateDefaultPalette() {
		// palette = new color[9];
		// palette[0] = color(0);
		// palette[1] = color(255);
		// palette[2] = color(255, 0, 0);
		// palette[3] = color(0, 255, 0);
		// palette[4] = color(0, 0, 255);
		// palette[5] = color(255, 255, 0);
		// palette[6] = color(0, 255, 255);
		// palette[7] = color(255, 0, 255);
		// palette[8] = color(0, 255, 255);

		palette = new color[8];
		palette[0] = color(31,32,47);
		palette[1] = color(38,65,111);
		palette[2] = color(60,89,103);
		palette[3] = color(129,85,60);
		palette[4] = color(113,149,169);
		palette[5] = color(188,154,28);
		palette[6] = color(195,148,132);
		palette[7] = color(223,198,181);
	}


}
