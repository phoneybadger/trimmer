namespace Trimmer {
    public class Timeline: Gtk.Grid {
        private double _playback_duration;
        private double _playback_progress;
        public unowned Trimmer.VideoPlayer player {get; set construct;}

        public Gtk.Label duration_label {get; construct set;}
        public Gtk.Label progress_label {get; construct set;}

        // total length of the clip
        public double playback_duration {
            get {
                return _playback_duration;
            }
            set {
                double duration = value;
                if (duration < 0.0) {
                    debug ("Duration value less than zero, duration set to 0.0");
                    duration = 0.0;
                }

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

        /* Using a fractional coordinate system. i.e. normalized between 0-1.
           For ease of manipulation */
        private const double HITBOX_THRESHOLD = 0.015;

        /* Initializing to points inside the track to give a visual hint to the 
           user that the points can be manipulated */
        private int _trim_start;
        private int _trim_end;

        private double selection_start;
        private double selection_end;

        public int trim_start {
            get {
                return _trim_start;
            }
            set {
                _trim_start = value;
                if (playback_duration != 0) {
                    selection_start = _trim_start/playback_duration;
                }
            }
        }

        public int trim_end {
            get {
                return _trim_end;
            }
            set {
                _trim_end = value;
                if (playback_duration != 0) {
                    selection_end = _trim_end/playback_duration;
                }
            }
        }


        private double track_start = 0;
        private double track_end = 1;


        public bool is_grabbing = false;

        private Gtk.Allocation selection_allocation;
        private Gtk.Allocation track_allocation;
        private Gtk.Allocation progressbar_allocation;

        private Gtk.Box selection;
        private Gtk.Box progressbar;

        private const int TIMELINE_HEIGHT = 18;

        private enum end_points {
            SELECTION_START,
            SELECTION_END
        }
        private end_points grabbed_point;

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
            try {
                css_provider.load_from_path ("/home/adithyankv/Code/personal_projects/trimmer/src/timeline.css");
            } catch (Error e) {
                critical (e.message);
            }
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

            track.get_style_context ().add_class ("test");

            selection = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            selection.get_style_context ().add_class ("selection");

            progressbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = TIMELINE_HEIGHT,
            };
            progressbar.get_style_context ().add_class ("progress");

            track.size_allocate.connect (() => {
                track.get_allocation (out track_allocation);
                refresh_selection ();
                update_progress ();
            });

            eventbox.motion_notify_event.connect ((event) => {
                var mouse_x = get_fractional_coordinate (event.x);
                if (is_mouse_over_selection_start (mouse_x) ||
                    is_mouse_over_selection_end (mouse_x)) {
                    window.cursor = resize_cursor;
                } else {
                    window.cursor = default_cursor;
                }

                if (is_grabbing) {
                    move_point (grabbed_point, mouse_x);
                    if (grabbed_point == end_points.SELECTION_START) {
                        playback_progress = selection_start;
                        player.playback.progress = selection_start;
                    } else {
                        playback_progress = selection_end;
                        player.playback.progress = selection_end;
                    }
                }
            });

            eventbox.leave_notify_event.connect ((event) => {
                window.cursor = default_cursor;
            });

            eventbox.button_press_event.connect ((event) => {
                var mouse_x = get_fractional_coordinate (event.x);
                if (is_mouse_over_selection_start (mouse_x) ||
                    is_mouse_over_selection_end (mouse_x)) {
                    is_grabbing = true;
                    grab_point (mouse_x);
                }
                playback_progress = mouse_x;
                player.playback.progress = playback_progress;
            });

            eventbox.button_release_event.connect (() => {
                is_grabbing = false;
            });

            track.add (progressbar);
            track.add (selection);

            eventbox.add (track);

            attach (progress_label, 0, 0);
            attach (eventbox, 1, 0);
            attach (duration_label, 2, 0);
        }

        private void move_point (end_points grabbed_point, double mouse_x) {
            // TODO: adjust min seperation to correspond to minimum unit of time
            var min_seperation = 0.01;
            if (grabbed_point == end_points.SELECTION_START) {
                if (mouse_x < track_start) {
                    selection_start = track_start;
                } else if (mouse_x >= selection_end - min_seperation){
                    selection_start = selection_end - min_seperation;
                } else {
                    selection_start = mouse_x;
                }
                trim_start = (int) (selection_start * playback_duration);
            } else {
                if (mouse_x > track_end) {
                    selection_end = track_end;
                } else if (mouse_x < selection_start + min_seperation) {
                    selection_end = selection_start + min_seperation;
                } else {
                    selection_end = mouse_x;
                }
                trim_end = (int) (selection_end * playback_duration);
            }
            refresh_selection ();
        }

        private void grab_point (double mouse_x) {
            /* comparing distances instead of just checking hover
               to handle the case where the points are really
               close together */
            var distance_to_start = (mouse_x - selection_start).abs ();
            var distance_to_end = (mouse_x - selection_end).abs ();
            if (distance_to_start < distance_to_end) {
                grabbed_point = end_points.SELECTION_START;
            } else {
                grabbed_point = end_points.SELECTION_END;
            }
        }

        private void refresh_selection () {
            var offset = track_allocation.x;
            selection_allocation.y = track_allocation.y;
            selection_allocation.height = track_allocation.height;
            selection_allocation.x = get_pixel_coordinate (selection_start);
            selection_allocation.width = get_pixel_coordinate (
                selection_end - selection_start) - offset;
            selection.size_allocate (selection_allocation);
        }

        private void update_progress () {
            /* change progress timestamp label and also progressbar */
            progress_label.label = Granite.DateTime.seconds_to_time (
                    (int) (playback_progress * playback_duration));
            
            /* To prevent the progressbar from glitching out for near zero 
               progress. Chosen to be twice the border radius as this seems
               to look nice. There must be a better way to do this.*/
            int min_width = 6;
            progressbar_allocation = track_allocation;
            var width = (int) (playback_progress * track_allocation.width);
            if (width > min_width) {
                progressbar_allocation.width = width;
            } else {
                progressbar_allocation.width = min_width;
            }
            progressbar.size_allocate (progressbar_allocation);
        }

        private int get_pixel_coordinate (double fractional_coordinate) {
            /* convert back from the 0-1 fractional coordinate system to the
               pixel locations on screen so as to draw the UI */
            var offset = track_allocation.x;
            return (int) (offset + (fractional_coordinate * track_allocation.width));
        }

        private double get_fractional_coordinate (double pixel_coordinate) {
            /* convert from pixel location inside the windows coordinate system
               to a 0-1 coordinate system where 0 is beginning of track and 1 is
               the end */
            var offset = track_allocation.x;
            return (pixel_coordinate - offset)/track_allocation.width;
        }

        private bool is_mouse_over_selection_start (double mouse_x) {
            return (mouse_x - selection_start).abs () < HITBOX_THRESHOLD;
        }

        private bool is_mouse_over_selection_end (double mouse_x) {
            return (mouse_x - selection_end).abs () < HITBOX_THRESHOLD;
        }
    }
}
