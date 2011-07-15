set -i
 
#filename="$(date +%Y%m%d_%a_%H-%M-%S).mp4"
filename="test.mp4"
preset="slow"
uri="rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480"

GST_DEBUG=moo:5 gst-launch -e \
  multiqueue name=mq0 \
  multiqueue name=mq1 \
  mp4mux streamable=true name=muxer0 ! filesink location="buffer_$filename" \
  mp4mux streamable=true name=muxer1 ! filesink location="$filename" \
  uridecodebin uri="$uri" name=dec \
  dec.src0 ! tee name=taudio0 ! tee name=taudio1 \
  dec.src1 ! tee name=tvideo0 ! tee name=tvideo1 \
  taudio0. ! queue leaky=2 max-size-time=1100000000 min-threshold-time=1000000000 max-size-bytes=0 max-size-buffers=0 ! mq0.sink0 \
  tvideo0. ! queue leaky=2 max-size-time=1100000000 min-threshold-time=1000000000 max-size-bytes=0 max-size-buffers=0 ! mq0.sink1 \
  mq0.src0 ! queue ! audioconvert ! lame ! muxer0. \
  mq0.src1 ! queue ! ffmpegcolorspace ! x264enc speed-preset=$preset pass=qual quantizer=22 ! muxer0. \
  taudio1. ! queue ! mq1.sink0 \
  tvideo1. ! queue ! mq1.sink1 \
  mq1.src0 ! queue ! audioconvert ! lame ! muxer1. \
  mq1.src1 ! queue ! ffmpegcolorspace ! x264enc speed-preset=$preset pass=qual quantizer=22 ! muxer1.

# With Multiqueue
#gst-launch-0.10 multiqueue name=mq  filesrc location=src1.gdp ! gdpdepay name=video  filesrc location=src0.gdp ! gdpdepay name=audio  mp4mux name=muxer ! filesink 
# location=src-muxed.mp4   audio. ! mq.sink0  video. ! mq.sink1  mq.src0 ! audioconvert ! lame ! muxer.  mq.src1 ! x264enc ! muxer.


# Getting raw type
# gst-launch-0.10 -v filesrc location=src1.gdp ! gdpdepay ! fakesink |grep depay

# Getting raw output
# gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec  dec.src0 ! gdppay ! filesink location=src0.gdp  dec.src1 ! gdppay ! filesink location=src1.gdp
