gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec mp4mux name=muxer ! filesink location=src-muxed.mp4  dec.src0 ! queue ! audioconvert ! lame ! muxer. dec.src1 ! queue ! x264enc ! muxer.

# Getting raw type
# gst-launch-0.10 -v filesrc location=src1.gdp ! gdpdepay ! fakesink |grep depay

# Getting raw output
# gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec  dec.src0 ! gdppay ! filesink location=src0.gdp  dec.src1 ! gdppay ! filesink location=src1.gdp
