namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.Timeline timeline {get; set;}
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        private Gtk.Button play_button;
        public Trimmer.Controllers.TrimController trim_controller;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            video_player = new VideoPlayer (this);
            trim_controller = new Controllers.TrimController ();

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                valign = Gtk.Align.CENTER
            };
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");
            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            timeline = new Timeline (video_player);
            timeline_box.pack_start (play_button, false, false, 0);
            timeline_box.pack_start (timeline, false, true, 0);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };
            var trim_button = new Gtk.Button.with_label ("Trim") {
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

            var start_entry = new Trimmer.TimeStampEntry ();
            var end_entry = new Trimmer.TimeStampEntry ();

            // clamp values to within clip bounds if user enters values outside range
            start_entry.notify ["time"].connect (() => {
                if (start_entry.time < 0) {
                    start_entry.time = 0;
                }
            });

            end_entry.notify ["time"].connect (() => {
                if (end_entry.time > trim_controller.duration) {
                    end_entry.time = (int) trim_controller.duration;
                }
            });

            video_player.video_loaded.connect((duration) => {
                timeline.playback_duration = duration;
                trim_controller.duration = duration;
            });

            // Change UI to show if trim can be performed
            trim_controller.notify ["is-valid-trim"].connect(() => {
                trim_button.sensitive = trim_controller.is_valid_trim;
                start_entry.is_valid = trim_controller.is_valid_trim;
                end_entry.is_valid = trim_controller.is_valid_trim;
            });

            // Keep UI in sync with controller
            realize.connect (() => {
                start_entry.bind_property (
                    "time",
                    trim_controller,
                    "trim_start_time",
                    BindingFlags.BIDIRECTIONAL
                );

                end_entry.bind_property (
                    "time",
                    trim_controller,
                    "trim_end_time",
                    BindingFlags.BIDIRECTIONAL
                );
            });

            start_end_box.pack_start (start_label, false, false, 10);
            start_end_box.pack_start (start_entry, false, false, 10);
            start_end_box.pack_start (end_label, false, false, 10);
            start_end_box.pack_start (end_entry, false, false, 10);

            pack_start (video_player, true, true, 0);
            pack_start (timeline_box, false, false, 0);
            pack_start (start_end_box, false, false, 0);
            pack_start (button_box, false, false, 0);
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
