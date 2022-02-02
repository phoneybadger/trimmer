namespace Trimmer {
    public class Timeline: Gtk.Grid {
        private double _playback_duration;
        private double _playback_progress;
        public unowned Trimmer.VideoPlayer player {get; set construct;}

        public Gtk.Label duration_label {get; construct set;}
        public Gtk.Label progress_label {get; construct set;}

        public double playback_duration {
            get {
                return _playback_duration;
            }
            set {
                double duration = value;
                _playback_duration = duration;
                duration_label.label = Granite.DateTime.seconds_to_time ((int) duration);
                }
        }

        public double playback_progress {
            get {
                return _playback_progress;
            }
            set {
                double progress = value;
                if (progress < 0.0) {
                    debug ("Progress value less than 0.0, progress set to 0.0");
                    progress = 0.0;
                } else if (progress > 1.0) {
                    debug ("Progress value greater than 1.0, progress set to 1.0");
                    progress = 1.0;
                }
                _playback_progress = progress;
                update_progress ();
            }
        }

        private int _start_time;
        private int _end_time;

        public int start_time {
            get {
                return _start_time;
            } set {
                _start_time = value;
            }
        }

        public int end_time {
            get {
                return _end_time;
            } set {
                _end_time = value;
            }
        }

        private double _selection_start;
        private double _selection_end;

        public double selection_start {
            get {
                return _selection_start;
            } set {
                _selection_start = value;
            }
        }

        public double selection_end {
            get {
                return _selection_end;
            } set {
                _selection_end = value;
            }
        }

        private Gtk.Allocation track_allocation;
        private Gtk.Allocation progressbar_allocation;
        private Gtk.Allocation selection_allocation;

        private Gtk.Box progressbar;
        private Gtk.Box selection;

        private const int TIMELINE_HEIGHT = 18;
        private const int TIMELINE_BORDER = 1;
        private const double HITBOX_THRESHOLD = 0.015;

        public bool is_grabbing {get; set;}

        public Timeline (Trimmer.VideoPlayer player) {
            Object (
                player : player
            );
            playback_duration = player.playback.duration;
        }

        construct {
            column_spacing = 5;
            valign = Gtk.Align.CENTER;
            var style_context = get_style_context ();

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/adithyankv/trimmer/timeline.css");

            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            var window = Gdk.get_default_root_window ();
            var display = window.get_display ();
            var default_cursor = new Gdk.Cursor.from_name (display, "default");
            var resize_cursor = new Gdk.Cursor.from_name (display, "col-resize");
            window.cursor = default_cursor;

            var eventbox = new Gtk.EventBox ();
            eventbox.add_events (Gdk.EventMask.POINTER_MOTION_MASK|
                Gdk.EventMask.ENTER_NOTIFY_MASK|
                Gdk.EventMask.BUTTON_PRESS_MASK|
                Gdk.EventType.LEAVE_NOTIFY);

            duration_label = new Gtk.Label (null);
            progress_label = new Gtk.Label (null);
            duration_label.margin_end = progress_label.margin_start = 3;

            var track = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
                hexpand = true,
            };
            track.get_style_context ().add_class (Gtk.STYLE_CLASS_TROUGH);

            progressbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            progressbar.get_style_context ().add_class (Gtk.STYLE_CLASS_SCALE);

            selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            selection.get_style_context ().add_class ("selection");

            eventbox.button_press_event.connect ((event) => {
                is_grabbing = true;
                player.playback.playing = false;
                seek_timeline (event.x);
            });

            eventbox.button_release_event.connect (() => {
                is_grabbing = false;
            });

            eventbox.motion_notify_event.connect ((event) => {
                if (is_grabbing) {
                    seek_timeline (event.x);
                }

                if (!is_grabbing) {
                    if (is_mouse_over_selection (event.x)) {
                        window.cursor = resize_cursor;
                    } else {
                        window.cursor = default_cursor;
                    }
                }
            });

            eventbox.leave_notify_event.connect (() => {
                window.cursor = default_cursor;
            });

            track.size_allocate.connect (() => {
                track.get_allocation (out track_allocation);
                refresh_selection ();
                update_progress ();
            });

            // Pause the video when seeking/scrubbing
            bind_property (
                "is_grabbing",
                player.playback,
                "playing",
                BindingFlags.INVERT_BOOLEAN
            );

            notify ["start-time"].connect (() => {
                selection_start = start_time/playback_duration;
                refresh_selection ();
            });

            notify ["end-time"].connect (() => {
                selection_end = end_time/playback_duration;
                refresh_selection ();
            });

            track.add (progressbar);
            track.add (selection);
            eventbox.add (track);

            attach (progress_label, 0, 0);
            attach (eventbox, 1, 0);
            attach (duration_label, 2, 0);
        }

        private void seek_timeline (double mouse_x) {
            playback_progress = get_position_on_timeline (mouse_x);
            player.playback.progress = playback_progress;
        }

        private void update_progress () {
            /* change progress timestamp label and also the progress ui */
            progress_label.label = Granite.DateTime.seconds_to_time (
                    (int) (playback_progress * playback_duration));
            progressbar_allocation.x = track_allocation.x + TIMELINE_BORDER;
            progressbar_allocation.y = track_allocation.y + TIMELINE_BORDER;
            progressbar_allocation.height = Utils.max(0, track_allocation.height - 2 * TIMELINE_BORDER);
            var width = (int) (playback_progress * track_allocation.width);
            progressbar_allocation.width = Utils.max(0, width - 2 * TIMELINE_BORDER);
            progressbar.size_allocate (progressbar_allocation);
        }

        private double get_position_on_timeline (double pixel_coordinate) {
            /* convert from pixel location inside the window's coordinate system
               to a 0-1 coordinate system where 0 is beginning of track and 1 is
               the end */
            var offset = track_allocation.x;
            return (pixel_coordinate - offset)/track_allocation.width;
        }

        private int get_pixel_coordinate (double timeline_position) {
            var offset = track_allocation.x;
            return (offset + (int)(timeline_position * track_allocation.width));
        }

        private void refresh_selection () {
            selection_allocation.x = get_pixel_coordinate (selection_start);
            selection_allocation.y = track_allocation.y;
            selection_allocation.height = track_allocation.height;
            selection_allocation.width = get_pixel_coordinate (selection_end - selection_start);
            if (selection_allocation.width < 0) {
                selection_allocation.width = 0;
            }
            selection.size_allocate (selection_allocation);
        }

        private bool is_mouse_over_selection (double mouse_x) {
            var mouse_timeline_pos = get_position_on_timeline (mouse_x);
            var distance_start = (mouse_timeline_pos - selection_start).abs ();
            var distance_end = (mouse_timeline_pos - selection_end).abs ();
            return (distance_start < HITBOX_THRESHOLD ||
                    distance_end < HITBOX_THRESHOLD);
        }
    }
}
