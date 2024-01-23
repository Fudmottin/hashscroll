#!/bin/bash

# The number of lines you want in each image
LINES_PER_FRAME=21

# Temporary directory for the images
mkdir temp_images

# Counter for the image filenames without any suffixes.
COUNTER=0

# Hold LINES_PER_FRAME lines in an array as a buffer
BUFFER=()

# Loop through the file, creating an image every LINES_PER_FRAME lines
cat hexdata.txt | while read LINE; do
  
  # Add current line to buffer and remove oldest if size exceeds LINES_PER_FRAME
  BUFFER+=("$LINE")
  if (( ${#BUFFER[@]} > $LINES_PER_FRAME )); then
    BUFFER=("${BUFFER[@]:1}")
  fi
  
  # Write buffered lines into txt file 
  printf "%s\n" "${BUFFER[@]}" > temp_images/frame$COUNTER.txt
  
  # Generate the image using ImageMagick and Menlo font from system fonts
  # This was run on MacOS. Linux, Windows, etc will probably have font files
  # in other locations. Font size and LINES_PER_FRAME were chosen for the
  # size of the images.
  convert -size 3840x2160 -background black -font "/System/Library/Fonts/Menlo.ttc" -pointsize 84 -fill '#00ff00' \
    -gravity Center label:@temp_images/frame$COUNTER.txt temp_images/frame$COUNTER.png
  
   # Increment counter for next frame
   let COUNTER=COUNTER+1
    
done

# Combine all frames into a video with FFmpeg.
ffmpeg -framerate 60 -i temp_images/frame%d.png -pix_fmt yuv422p10le -c:v prores -profile:v 3 output.mov

