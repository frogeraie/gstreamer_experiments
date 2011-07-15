gst-launch uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec ! \
  multiqueue name=mq  \
  dec.src1 ! mq.sink1  \
  mp4mux name=mux ! filesink location=out.mp4  \
  mq.src0 ! ffmpegcolorspace ! ffenc_mpeg4 ! mux. \
  mq.src1 ! lame ! mux.
