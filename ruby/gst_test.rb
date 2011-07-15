require 'gst'

path = File.expand_path "~/Dropbox/CCTV/1856071.mp4"
src = "uridecodebin uri=rtsp://hackeron:password@192.168.0.252/nphMpeg4/g726-640x480 name=dec"
# src = "filesrc location=%s ! decodebin2" % path
#
pipeline = Gst::Parse.launch('
   %s ! videorate tolerance=30000000 ! videoscale ! ffmpegcolorspace ! motioncells postallmotion=true threshold=0.05 gridx=32 gridy=32 ! ffmpegcolorspace ! ximagesink' % [ src ] )
   # %s ! videorate ! videoscale ! ffmpegcolorspace ! ximagesink' % [ src ] )
   # %s ! videorate ! videoscale ! ffmpegcolorspace ! "video/x-raw-yuv,width=320,height=240,framerate=10/1" ! ximagesink' % [ src ] )

# Main loop
loop = GLib::MainLoop.new(nil, false)

# Add custom tasks
GLib::Timeout.add(1000) {
  q = Gst::QueryPosition.new(Gst::Format::TIME)
  pipeline.query(q)
  duration = q.parse[1] / 1000000.0 / 1000
  print "%s                  \r" % [ duration ]
  if duration > 60 * 60
    pipeline.stop
    exit 0
  end
  true
}

# Watch pipeline bus for messages
bus = pipeline.bus
bus.add_watch do |bus, message|
  case message.type
  when Gst::Message::EOS
    pipeline.stop
    exit 0
  when Gst::Message::ERROR
    p message.structure["debug"]
    pipeline.stop
    exit 1
  when Gst::Message::STATE_CHANGED
    p "%s: from: %s to %s (pending: %s)" % [
      message.type.name,
      message.structure["old-state"].name.sub("GST_STATE_",""),
      message.structure["new-state"].name.sub("GST_STATE_",""),
      message.structure["pending-state"].name.sub("GST_STATE_","") ]
  when Gst::Message::STREAM_STATUS
    p "%s: %s %s" % [
      message.type.name,  message.structure["owner"].name,
      message.structure["object"].name ]
  when Gst::Message::TAG
    entries_str = ''
    message.structure.entries.each do |a,b|
      entries_str += "%s=%s, " % [ a,b ]
    end
    p "%s: %s" % [ message.type.name, entries_str[0..-3] ]
  when Gst::Message::ASYNC_DONE
    p "%s %s" % [ message.type.name, message.structure ]
  when Gst::Message::NEW_CLOCK
    p "%s: %s" % [ message.type.name, message.structure["clock"].name ]
  when Gst::Message::ELEMENT
    p message.structure
  when Gst::Message::QOS
    # Used in ximagesink - nothing interesting there for us
  else
    p "--"
    p message.type.name
    p message.type
    p message.structure
    p "--"
  end
  true
end

# Start
pipeline.play
loop.run
puts
