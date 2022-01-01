namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;
        private const int HITBOX_THRESHOLD = 10;

        /* Using a fractional coordinate system. i.e. values normalized to the
           0-1 range within the width of the track. For ease of manipulation */

        /* Initializing to points inside the track to give a visual hint to the 
           user that the points can be manipulated */
        private double selection_start = 1.0/4.0;
        private double selection_end = 3.0/4.0;

        private int track_start = 0;
        private int track_end = 1;

        private Gtk.Allocation selection_allocation;
        private Gtk.Allocation track_allocation;

        private Gtk.Box selection;

        public TestTimeline () {
            add_events (Gdk.EventMask.POINTER_MOTION_MASK|
                        Gdk.EventMask.ENTER_NOTIFY_MASK|
                        Gdk.EventMask.BUTTON_PRESS_MASK|
                        Gdk.EventType.LEAVE_NOTIFY);
        }

        construct {
            var content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var track = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
                hexpand = true,
                margin_start = 10,
                margin_end = 10,
            };
            track.get_style_context ().add_class ("test");

            selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            selection.get_style_context ().add_class ("selection");

            track.size_allocate.connect (() => {
                track.get_allocation (out track_allocation);

                refresh_selection ();
            });

            track.add(selection);
            content_box.add(track);

            add(content_box);
        }

        private void refresh_selection () {
            selection_allocation.y = track_allocation.y;
            selection_allocation.height = track_allocation.height;
            selection_allocation.x = get_pixel_coordinate (selection_start);
            selection_allocation.width = get_pixel_coordinate (selection_end - selection_start);
            selection.size_allocate (selection_allocation);
        }

        private int get_pixel_coordinate (double fractional_coordinate) {
            /* convert back from the 0-1 fractional coordinate system to the
               pixel locations on screen so as to draw the UI */
            return (int) (fractional_coordinate * (track_allocation.width - track_allocation.x));
        }
    }
}
