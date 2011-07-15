#find ~/Dropbox/Desktop/testing/noise-testing/tests/ -type f | while read filename; do
find ~/Dropbox/CCTV/ -type f | grep -v "\.jpg$" | while read filename; do
  echo " *** $filename" >&2

  time GST_DEBUG=nothing:5 gst-launch -e --quiet \
    filesrc location="$filename" ! decodebin2 name=dec \
    dec. ! queue ! videorate ! videoscale ! ffmpegcolorspace ! 'video/x-raw-yuv,width=640,height=480,framerate=3/1,format=(fourcc)I420' ! fdsink

  #time GST_DEBUG=nothing:5 gst-launch -e --quiet \
  #  filesrc location="/root/Dropbox/Desktop/testing/noise-testing/tests/test_blackscreen.avi" ! decodebin2 name=dec \
  #  dec. ! queue ! videorate ! videoscale ! ffmpegcolorspace ! 'video/x-raw-yuv,width=640,height=480,framerate=3/1,format=(fourcc)I420' ! fdsink
done
