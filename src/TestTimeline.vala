namespace Trimmer {
    public class TestTimeline: Gtk.EventBox {
        private const int TIMELINE_HEIGHT = 24;
        private const int HITBOX_THRESHOLD = 10;

        /* Normalizing coordinates from 0-1 for ease of use */
        private double selection_start = ((double) 1)/4;
        private double selection_end = ((double) 3)/4;
        private Gtk.Allocation selection_allocation;
        private Gtk.Allocation track_allocation;

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

            var selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            selection.get_style_context ().add_class ("selection");

            track.size_allocate.connect (() => {
                track.get_allocation (out track_allocation);
                selection_allocation = track_allocation;
                selection_allocation.x = pixel_coordinates (selection_start);
                selection_allocation.width = pixel_coordinates (selection_end) 
                                            - pixel_coordinates (selection_start);
                selection.size_allocate (selection_allocation);
            });

            track.add(selection);
            content_box.add(track);

            add(content_box);
        }

        private int pixel_coordinates (double normalized_coordinate) {
            var start = track_allocation.x;
            var pixel_coordinate = start + (normalized_coordinate * track_allocation.width);
            return (int) pixel_coordinate;
        }
    }
}
