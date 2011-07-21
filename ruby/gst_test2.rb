require 'gst'

pipeline = Gst::Pipeline.new

# Source
source = Gst::ElementFactory.make("filesrc")
source.location = File.expand_path('~/Dropbox/VPN/Public/18-31-18.mkv')

# Decodebin
decodebin = Gst::ElementFactory.make("decodebin2")

# Sink
sink = Gst::ElementFactory.make("fakesink")

# Add element objects to pipeline
pipeline.add(source, decodebin, sink)

# Link elements
source >> decodebin >> sink

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
