namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;
        private const int HITBOX_THRESHOLD = 10;
        private int selection_start;
        private int selection_end;
        private int track_start;
        private int track_end;
        private bool is_grabbing;
        private trim_points element_being_resized;

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
            var normal_cursor = new Gdk.Cursor.from_name (Gdk.Display.get_default (), "default");
            var resize_cursor = new Gdk.Cursor.from_name (Gdk.Display.get_default (), "ew-resize");
            Gdk.get_default_root_window ().set_cursor (normal_cursor);

            var track = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
                hexpand = true,
                margin_start = 10,
                margin_end = 10,
            };
            track.get_style_context ().add_class ("test");
            var fixed = new Gtk.Fixed ();
            var selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
                width_request = 100,
            };
            selection.get_style_context ().add_class ("selection");

            /* Changing mouse cursor */
            motion_notify_event.connect ((event) => {
                Gtk.Allocation allocation;
                selection.get_allocation (out allocation);

                Gtk.Allocation track_allocation;
                track.get_allocation (out track_allocation);
                track_start = track_allocation.x;
                track_end = track_start + track_allocation.width;

                selection_start = allocation.x;
                selection_end = allocation.x + allocation.width;

                var mouse_x = event.x;

                var hitbox_threshold = 10;
                if (is_mouse_over_resize_bounds (mouse_x)) {
                    Gdk.get_default_root_window ().set_cursor (resize_cursor);
                } else {
                    Gdk.get_default_root_window ().set_cursor (normal_cursor);
                }

                if (is_grabbing) {
                    if (element_being_resized == trim_points.TRIM_START) {
                        if (mouse_x > track_start) {
                            print ("resizing start");
                        }
                    } else if (element_being_resized == trim_points.TRIM_END) {
                        if (mouse_x < track_end) {
                            allocation.width = (int) (mouse_x - track_start);
                            selection.size_allocate (allocation);
                        }
                    }
                }
            });

            leave_notify_event.connect (() => {
                Gdk.get_default_root_window ().set_cursor (normal_cursor);
            });

            button_press_event.connect ((event) => {
                if (is_mouse_over_resize_bounds (event.x)) {
                    is_grabbing = true;
                    if (is_mouse_over_trim_start (event.x)) {
                        element_being_resized = trim_points.TRIM_START;
                    } else {
                        element_being_resized = trim_points.TRIM_END;
                    }
                }
            });

            button_release_event.connect (() => {
                is_grabbing = false;
            });

            track.size_allocate.connect (() => {
                var width = track.get_allocated_width ();
                selection.width_request = width/2;
            });

            fixed.put (selection, 0, 0);

            track.add (fixed);

            content_box.add(track);

            add(content_box);
        }

        private bool is_mouse_over_resize_bounds (double mouse_x) {
            return is_mouse_over_trim_start (mouse_x) || is_mouse_over_trim_end (mouse_x);
        }

        private bool is_mouse_over_trim_start (double mouse_x) {
            return (mouse_x - selection_start).abs() < HITBOX_THRESHOLD;
        }

        private bool is_mouse_over_trim_end (double mouse_x) {
            return (mouse_x - selection_end).abs() < HITBOX_THRESHOLD;
        }
    }
}
