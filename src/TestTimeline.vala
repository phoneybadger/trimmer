namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;
        private const int HITBOX_THRESHOLD = 10;
        private bool is_initialized = false;

        private int selection_start;
        private int selection_end;

        private int track_start;
        private int track_end;

        private Gtk.Allocation selection_allocation;
        private Gtk.Allocation track_allocation;

        private Gtk.Box selection;

        private enum trim_points{
            TRIM_START,
            TRIM_END
        }

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
                track_start = track_allocation.x;
                track_end = track_start + track_allocation.width;

                if (! is_initialized) {
                    initialize_selection ();
                }

                refresh_selection ();
            });

            track.add(selection);
            content_box.add(track);

            add(content_box);
        }

        private void initialize_selection () {
            /* Initializing the selection to 1/4 and 3/4 of the track to hint 
               at the user that the points can be manipulated */
            var track_width = track_end - track_start;
            selection_start = (int) (1/4.0 * track_width);
            selection_end = (int) (3/4.0 * track_width);
            refresh_selection ();
            is_initialized = true;
        }

        private void refresh_selection () {
            selection_allocation.y = track_allocation.y;
            selection_allocation.height = track_allocation.height;
            selection_allocation.x = selection_start;
            selection_allocation.width = selection_end - selection_start;
            selection.size_allocate (selection_allocation);
        }
    }
}
