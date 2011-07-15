gst-launch -e uridecodebin \
  uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec \
  mp4mux streamable=true name=mux ! filesink location="$(date +%Y%m%d_%a_%H-%M-%S).mp4" \
  dec. ! queue ! audioconvert ! lame ! mux. \
  dec. ! queue ! ffmpegcolorspace ! x264enc speed-preset=ultrafast pass=qual quantizer=22 ! mux.

# With Multiqueue
#gst-launch-0.10 multiqueue name=mq  filesrc location=src1.gdp ! gdpdepay name=video  filesrc location=src0.gdp ! gdpdepay name=audio  mp4mux name=muxer ! filesink 
# location=src-muxed.mp4   audio. ! mq.sink0  video. ! mq.sink1  mq.src0 ! audioconvert ! lame ! muxer.  mq.src1 ! x264enc ! muxer.


# Getting raw type
# gst-launch-0.10 -v filesrc location=src1.gdp ! gdpdepay ! fakesink |grep depay

# Getting raw output
# gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec  dec.src0 ! gdppay ! filesink location=src0.gdp  dec.src1 ! gdppay ! filesink location=src1.gdp
