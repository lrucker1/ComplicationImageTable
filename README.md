# ComplicationImageTable
Tool for debugging dynamically generated Apple Watch complication images

This is a test app for seeing what dynamically generated Apple Watch complication images will look like for different image template kinds and watch sizes, with thanks to http://www.glimsoft.com/02/18/watchos-complications/ for doing all the work to organize the numbers.

It's a Mac app so it's best used with drawing code that only needs a few tweaks to turn UI* to NS*.

I wrote this because the adjustments the Watch does to your images is not obvious (if your image is too large it silently clips, not scales) plus it's very time consuming to run all the variants in the simulator just to see what minor tweaks you might want to do at different sizes.

You don't need to provide all your image styles; it's flexible that way. It comes with simple and complex dial images as examples.
