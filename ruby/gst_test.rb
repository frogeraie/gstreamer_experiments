require 'gst'

pipeline = Gst::Pipeline.new

# Source
source = Gst::ElementFactory.make("rtmpsrc")
source.location = 'rtmp://cdn-sov-2.musicradio.com:80/LiveAudio/LBC973'

# Sink
a = Time.new
sink = Gst::ElementFactory.make("filesink")
sink.location = "%04i%02i%02i_%02i%02i_lbc.mp3" % [
  a.year, a.month, a.day, a.hour, a.min ]

# Add element objects to pipeline
pipeline.add(source, sink)

# Link elements
source >> sink

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
    puts message.structure["debug"]
    pipeline.stop
    exit 1
  else
    true
    # puts message.type.inspect
    # puts message.structure
  end
  true
end

# Start
pipeline.play
loop.run
puts
