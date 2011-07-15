uri="rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480"

GST_DEBUG=nothing:5 gst-launch -e --quiet \
  multiqueue name=mq \
  uridecodebin uri="$uri" name=dec \
  dec. ! mq. \
  mq.src0 ! queue ! videorate ! videoscale ! ffmpegcolorspace ! 'video/x-raw-yuv,width=640,height=480,framerate=3/1,format=(fourcc)I420' ! fdsink
  # y4menc
  
  #uridecodebin uri="$uri" name=dec \
