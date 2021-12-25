namespace Trimmer {
    public class TestTimeline: Gtk.Box {
        private int width;
        private int selection_start;
        // private int selection_end;
        public TestTimeline () {
            add_events (Gdk.EventMask.POINTER_MOTION_MASK|
                        Gdk.EventMask.ENTER_NOTIFY_MASK);
        }
        construct {
            height_request = 24;
            margin_start = 10;
            margin_end = 10;
            selection_start = 0;
            get_style_context ().add_class ("test");

            var eventbox = new Gtk.EventBox ();

            var fixed = new Gtk.Fixed ();

            var selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            selection.get_style_context ().add_class ("selection");
            selection.width_request = 40;
            selection.height_request = 24;

            size_allocate.connect (() => {
                width = get_allocated_width ();
                selection.width_request = width/2;
            });

            add_events (Gdk.EventMask.POINTER_MOTION_MASK|
                        Gdk.EventMask.ENTER_NOTIFY_MASK);

            enter_notify_event.connect (() =>{print("yay");});
            motion_notify_event.connect ((event) => {
                print ("yay");
                print("%f",event.x);
            });
            add (eventbox);
            // fixed.put (selection, selection_start, 0);
        }
    }
}
