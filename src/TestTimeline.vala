namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;

        /* Using a fractional coordinate system. i.e. values normalized to the
           0-1 range within the width of the track. For ease of manipulation */
        private const double HITBOX_THRESHOLD = 0.015;

        /* Initializing to points inside the track to give a visual hint to the 
           user that the points can be manipulated */
        private double selection_start = 1.0/4.0;
        private double selection_end = 3.0/4.0;

        private double track_start = 0;
        private double track_end = 1;

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
            var window = Gdk.get_default_root_window ();
            var display = window.get_display ();
            var default_cursor = new Gdk.Cursor.from_name (display, "default");
            var resize_cursor = new Gdk.Cursor.from_name (display, "col-resize");

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

            motion_notify_event.connect ((event) => {
                var mouse_x = get_fractional_coordinate (event.x);

                if (is_mouse_over_selection_start (mouse_x) ||
                    is_mouse_over_selection_end (mouse_x)) {
                    window.cursor = resize_cursor;
                } else {
                    window.cursor = default_cursor;
                }
            });

            leave_notify_event.connect ((event) => {
                window.cursor = default_cursor;
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

        private double get_fractional_coordinate (double pixel_coordinate) {
            return (pixel_coordinate / (track_allocation.width - track_allocation.x));
        }

        private bool is_mouse_over_selection_start (double mouse_x) {
            return (mouse_x - selection_start).abs () < HITBOX_THRESHOLD;
        }

        private bool is_mouse_over_selection_end (double mouse_x) {
            return (mouse_x - selection_end).abs () < HITBOX_THRESHOLD;
        }
    }
}
