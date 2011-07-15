#include <gst/gst.h>
#include <glib.h>
#include <string.h>
#include <stdlib.h>

//  gst-launch v4l2src device=/dev/video0 ! videoscale ! videorate !capsfilter "caps=video/x-raw-yuv,framerate=10/1" ! ffmpegcolorspace ! motioncells ! ffmpegcolorspace ! xvimagesink
int
main (int   argc,
      char *argv[])
{
  GstElement *pipeline, *source, *videor,*videos,*capsf, *colorsp0, *colorsp1, *dynelement, *sink;
  GstCaps* caps;
  char tmp[100];
  int i = 0;
//  GMainLoop *loop;
//  loop = g_main_loop_new (NULL, FALSE);

  /* Initialisation */
  gst_init (&argc, &argv);

  /* Create gstreamer elements */
  pipeline = 	gst_pipeline_new 			("moitoncells-pipeline");
  source   = 	gst_element_factory_make	("v4l2src", "vidsrc");
  videor   =	gst_element_factory_make	("videorate","videor");
  videos   =	gst_element_factory_make	("videoscale","videos");
  capsf	   =	gst_element_factory_make	("capsfilter", "capsf");
  colorsp0 = 	gst_element_factory_make	("ffmpegcolorspace", "colorspace0");
  dynelement =  gst_element_factory_make	("motioncells","mcells");
  colorsp1 = 	gst_element_factory_make	("ffmpegcolorspace", "colorspace1");
  sink     = 	gst_element_factory_make	("xvimagesink", "xv-image-sink");
//  sink     = 	gst_element_factory_make	("fakesink", "xv-image-sink");
  if (!pipeline || !source || !videor || !videos || !capsf || !colorsp0 || !dynelement || !colorsp1 || !sink) {
    g_printerr ("One element could not be created. Exiting.\n");
    return -1;
  }
  g_object_set (G_OBJECT (source), "device", "/dev/video0", NULL);

  caps = gst_caps_from_string( "video/x-raw-yuv,width=320,height=240,framerate=10/1" );
  g_object_set (G_OBJECT (capsf), "caps", caps, NULL);

  gst_bin_add_many (GST_BIN (pipeline),
                    source, videor,videos,capsf, colorsp0, dynelement, colorsp1, sink, NULL);

  gst_element_link_many (source,videor,videos, capsf, colorsp0, dynelement, colorsp1, sink, NULL);

  g_print ("Now playing\n");
  gst_element_set_state (pipeline, GST_STATE_PLAYING);

  g_print ("Running...\n");
//  g_main_loop_run (loop);
  g_print("change property here: example  some_property property_value \n");
  g_print("Quit with 'q' \n");
  gchar property[20];
  gchar value[100];
  int a = 4;
  while(TRUE){
	  scanf("%19s %99s",property,value);
	  printf("property: %s -> value: %s \n",property,value);

	  if((g_strcmp0(property,"q")==0) || (g_strcmp0(value,"q")==0))
	 		  break;
	  if((strlen(property)>0) && (strlen(value)>0)){
		  if(g_strcmp0(property,"sensitivity")==0)
			  g_object_set (G_OBJECT(dynelement), property, atof(value), NULL);
		  if(g_strcmp0(property,"datafile")==0)
			  g_object_set (G_OBJECT(dynelement), property, value, NULL);
		  if(g_strcmp0(property,"date")==0)
			  g_object_set (G_OBJECT(dynelement), property, atol(value), NULL);
		  if(g_strcmp0(property,"gridx")==0)
		  	  g_object_set (G_OBJECT(dynelement), property, atoi(value), NULL);
		  if(g_strcmp0(property,"gridy")==0)
		  	  g_object_set (G_OBJECT(dynelement), property, atoi(value), NULL);
		  if(g_strcmp0(property,"motionmaskcellspos")==0)
		  	  g_object_set (G_OBJECT(dynelement), property, value, NULL);
		  if(g_strcmp0(property,"motioncellsidx")==0)
		  	  g_object_set (G_OBJECT(dynelement), property, value, NULL);
	  }
  }

  gst_element_set_state (pipeline, GST_STATE_NULL);
  gst_object_unref(pipeline);
  return 0;
}
