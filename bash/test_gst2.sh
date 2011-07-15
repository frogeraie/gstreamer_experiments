gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec ! \
  multiqueue name=mq max-size-bytes=0 max-size-buffers=0 max-size-time=0 \
  dec.src1 ! mq.sink1  \
  mp4mux name=mux ! filesink location=out.mp4  \
  mq. ! ffmpegcolorspace ! ffenc_mpeg4 ! mux. \
  mq. ! audioconvert ! lame ! mux.
