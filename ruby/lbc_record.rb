# Date string for filenames
starttime = Time.new
$datestr = "%04i%02i%02i_%02i%02i" % [
  starttime.year, starttime.month, starttime.day, starttime.hour, starttime.min ]

# Redirect stdout and err to logfile (to inspect is something goes wrong)
$stdout.reopen("logs/%s_lbc.out.txt" % $datestr, "w")
$stderr.reopen("logs/%s_lbc.err.txt" % $datestr, "w")

# Gstreamer pipeline
require 'gst'
uri = 'rtmp://cdn-sov-2.musicradio.com:80/LiveAudio/LBC973'
pipeline = Gst::Parse.launch("\
  rtmpsrc location=%s ! decodebin2 ! audiorate tolerance=30000000 ! audioconvert ! vorbisenc ! oggmux ! filesink location=%s_lbc.ogg" % [ 
    uri, $datestr ])

#rtmpsrc location=%s ! decodebin2 ! audioconvert ! wavenc ! decodebin ! audioconvert ! vorbisenc ! oggmux ! filesink location=%s_lbc.ogg" % [ 
#decodebin2 ! audiorate ! audioconvert ! vorbisenc ! oggmux ! \
# Print everything with timestamp
$last_msg=''
def p(msg)
   if $last_msg != msg
     puts "%s :: %s" % [ Time.new, msg ]
     $last_msg = msg
   end
end

# Helper function to get & write information about what we are recording
require 'hpricot'
require 'open-uri'
$time = nil
$presenter = nil
$description = nil
def write_show_metadata()
    doc = Hpricot(open("http://www.lbc.co.uk"))
    showinfo = doc.at("div > #showInfo")
    File.open('%s_lbc.txt' % $datestr, 'a+') do |f1|  
      if $time != showinfo.at(".time").to_plain_text
        f1.puts "Time: %s\n" % showinfo.at(".time").to_plain_text
        $time = showinfo.at(".time").to_plain_text
      end
      if $presenter != showinfo.at(".showTitle").to_plain_text
        f1.puts "Presenter: %s\n" % showinfo.at(".showTitle").to_plain_text
       $presenter = showinfo.at(".showTitle").to_plain_text
      end
      if $description != showinfo.at(".description").to_plain_text.strip
        f1.puts "Description: %s\n" % showinfo.at(".description").to_plain_text.strip
       $description = showinfo.at(".description").to_plain_text.strip 
      end
    end
    true
end

# Check and write show metadata every 10 minutes
GLib::Timeout.add(1000*60*10) {
  write_show_metadata
  true
}

# Query every second
GLib::Timeout.add(1000) {
  q = Gst::QueryPosition.new(Gst::Format::TIME)
  pipeline.query(q)
  # Duration either -1 (not started), or calculate seconds
  duration = q.parse[1] == -1 ? -1 : q.parse[1] / 1000000.0 / 1000 
  # p "Duration: %.2f sec" % duration
  if duration > 60 * 60 # 60 minutes
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

loop = GLib::MainLoop.new(nil, false)
pipeline.play
loop.run
