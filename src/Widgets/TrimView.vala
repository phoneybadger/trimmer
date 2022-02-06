namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.Timeline timeline {get; set;}
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        public Trimmer.Controllers.TrimController trim_controller;

        private Gtk.Button play_button;
        private Trimmer.TimeStampEntry start_entry;
        private Trimmer.TimeStampEntry end_entry;
        private Gtk.Button trim_button;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            create_layout ();

            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            video_player.video_loaded.connect((duration) => {
                trim_controller.duration = duration;
                timeline.playback_duration = duration;
                timeline.initialize_selection ();
            });

            timeline.selection_changed.connect ((start, end) => {
                var start_time = (int) (start * trim_controller.duration);
                var end_time = (int) (end *  trim_controller.duration);
                start_entry.text = Granite.DateTime.seconds_to_time (start_time);
                end_entry.text = Granite.DateTime.seconds_to_time (end_time);
            });

            start_entry.changed.connect (on_entry_changed);
            end_entry.changed.connect (on_entry_changed);
        }

        private void create_layout () {
            video_player = new VideoPlayer (this);
            trim_controller = new Controllers.TrimController ();

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                valign = Gtk.Align.CENTER
            };
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");

            timeline = new Timeline (video_player);
            timeline_box.pack_start (play_button, false, false, 0);
            timeline_box.pack_start (timeline, false, true, 0);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };

            trim_button = new Gtk.Button.with_label ("Trim") {
                margin = 5
            };
            trim_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_box.pack_end (trim_button);

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 10,
                halign = Gtk.Align.CENTER
            };

            var start_label = new Gtk.Label ("Start");
            var end_label = new Gtk.Label ("End");

            start_entry = new Trimmer.TimeStampEntry ();
            end_entry = new Trimmer.TimeStampEntry ();

            start_end_box.pack_start (start_label, false, false, 10);
            start_end_box.pack_start (start_entry, false, false, 10);
            start_end_box.pack_start (end_label, false, false, 10);
            start_end_box.pack_start (end_entry, false, false, 10);

            pack_start (video_player, true, true, 0);
            pack_start (timeline_box, false, false, 0);
            pack_start (start_end_box, false, false, 0);
            pack_start (button_box, false, false, 0);
        }
        
        private void on_entry_changed () {
            if (start_entry.is_valid_timestamp ()) {
                var start_time = Utils.convert_timestamp_to_seconds (start_entry.text);
                // clamp to bounds
                if (start_time > trim_controller.duration) {
                    start_time = (int) trim_controller.duration;
                    start_entry.text = Granite.DateTime.seconds_to_time (start_time);
                }
                trim_controller.trim_start_time = start_time;
                timeline.selection_start = start_time/trim_controller.duration;
            }
            if (end_entry.is_valid_timestamp ()) {
                var end_time = Utils.convert_timestamp_to_seconds (end_entry.text);
                // clamp to bounds
                if (end_time > trim_controller.duration) {
                    end_time = (int) trim_controller.duration;
                    end_entry.text = Granite.DateTime.seconds_to_time (end_time);
                }
                trim_controller.trim_end_time = end_time;
                timeline.selection_end = end_time/trim_controller.duration;
            }

            if (start_entry.is_valid_timestamp () && is_valid_trim ()) {
                start_entry.is_valid = true;
            } else {
                start_entry.is_valid = false;
            }

            if (end_entry.is_valid_timestamp () && is_valid_trim ()) {
                end_entry.is_valid = true;
            } else {
                end_entry.is_valid = false;
            }
            
            trim_button.sensitive = (start_entry.is_valid && end_entry.is_valid);
        }

        private bool is_valid_trim () {
            var start = trim_controller.trim_start_time;
            var end = trim_controller.trim_end_time;
            return (start < end);
        }

        public void update_play_button_icon () {
            if (video_player.playback.playing) {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-pause-symbolic";
            } else {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-start-symbolic";
            }
        }
    }
}
