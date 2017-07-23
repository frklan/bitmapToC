# BitmapToC
A simple Mac OS X app that converts .bmp files to C arrays that can be used for, for example, LCD's.

<img src=BitmapToCScreenshot.png>

I needed a tool to convert images to C-arrays to work with [Waveshare e-ink](http://www.waveshare.com/wiki/2.9inch_e-Paper_Module) displays. [Hoiberg's BitmapToC](https://github.com/hoiberg/bitmapToC) does an excellent job at that, however I needed the images to coded the images verticaly instead of horizontaly, so I forked his repo and added a few functions.

Any bugs or misstakes are mine, so don't blame anyone else.

##How to use

 1. Download the latest [release](https://github.com/frklan/bitmapToC/releases) and open the app. Drag and drop a .bmp file to the top area.
 2. Select how many bits (pixels) every array element should contain,
 3. select endcoding, and 
 4. hit 'convert'.

Note: Only works with bmp files with one bit per pixel.


## Distribution

Note that you'll need an valid paid Appler developer account to sign a distribtution and avoid Gatekeeper warnings.

 1. Set the bundle ID
 2. Set a developer team/id
 3. Compile the app for distribution
 4. Create a installer by issuing the command ```productbuild --component Bitmapper.app ./Bitmapper.pkg```in a bash shell

Alternatively, if you have a valid Apple developer account use Xcode to make it automagically.

## Encoding

TBD
