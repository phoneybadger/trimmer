namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;
        private int selection_start;
        private int selection_end;

        public TestTimeline () {
            add_events (Gdk.EventMask.POINTER_MOTION_MASK|
                        Gdk.EventMask.ENTER_NOTIFY_MASK|
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

            motion_notify_event.connect ((event) => {
                Gtk.Allocation allocation;
                selection.get_allocation (out allocation);

                selection_start = allocation.x;
                selection_end = allocation.x + allocation.width;

                var mouse_x = event.x;

                var hitbox_threshold = 10;
                if ((mouse_x - selection_start).abs() < hitbox_threshold ||
                    (mouse_x - selection_end).abs() < hitbox_threshold) {
                    Gdk.get_default_root_window ().set_cursor (resize_cursor);
                } else {
                    Gdk.get_default_root_window ().set_cursor (normal_cursor);
                }
            });

            leave_notify_event.connect (() => {
                Gdk.get_default_root_window ().set_cursor (normal_cursor);
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
    }
}
