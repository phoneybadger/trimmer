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

        private Gtk.Allocation track_allocation;
        private Gtk.Allocation progressbar_allocation;

        private Gtk.Box progressbar;

        private const int TIMELINE_HEIGHT = 18;

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
            track.get_style_context ().add_class ("timeline");

            progressbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            progressbar.get_style_context ().add_class ("progress");

            eventbox.button_press_event.connect ((event) => {
                is_grabbing = true;
                seek_timeline (event.x);
            });

            eventbox.button_release_event.connect (() => {
                is_grabbing = false;
            });

            eventbox.motion_notify_event.connect ((event) => {
                if (is_grabbing) {
                    seek_timeline (event.x);
                }
            });

            track.size_allocate.connect (() => {
                track.get_allocation (out track_allocation);
                update_progress ();
            });

            track.add (progressbar);

            eventbox.add (track);

            attach (progress_label, 0, 0);
            attach (eventbox, 1, 0);
            attach (duration_label, 2, 0);
        }

        private void seek_timeline (double mouse_x) {
                player.playback.playing = false;
                playback_progress = get_timeline_coordinate (mouse_x);
                player.playback.progress = playback_progress;
        }

        private void update_progress () {
            /* change progress timestamp label and also the progress ui */
            progress_label.label = Granite.DateTime.seconds_to_time (
                    (int) (playback_progress * playback_duration));
            progressbar_allocation = track_allocation;
            var width = (int) (playback_progress * track_allocation.width);
            progressbar_allocation.width = width;
            progressbar.size_allocate (progressbar_allocation);
        }

        private double get_timeline_coordinate (double pixel_coordinate) {
            /* convert from pixel location inside the window's coordinate system
               to a 0-1 coordinate system where 0 is beginning of track and 1 is
               the end */
            var offset = track_allocation.x;
            return (pixel_coordinate - offset)/track_allocation.width;
        }
    }
}
