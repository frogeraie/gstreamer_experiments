find ~/Dropbox/Desktop/testing/noise-testing/tests/ -type f | while read filename; do
 echo " *** $filename" >&2
 #ffmpeg -loglevel quiet -i "$filename" -f yuv4mpegpipe - >/dev/null
done
