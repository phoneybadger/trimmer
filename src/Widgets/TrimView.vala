namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.Timeline timeline {get; set;}
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        private Gtk.Button play_button;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            video_player = new VideoPlayer (this);

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                valign = Gtk.Align.CENTER
            };
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");
            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            // Initialize with 0 as no video will be loaded initially
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

            trim_button.clicked.connect (() => {
                window.trim_controller.trim_video ();
            });

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 10,
                halign = Gtk.Align.CENTER
            };

            var start_label = new Gtk.Label ("Start");
            var end_label = new Gtk.Label ("End");

            var start_entry = new Trimmer.TimeStampEntry ();
            var end_entry = new Trimmer.TimeStampEntry ();

            realize.connect (() => {
                start_entry.bind_property (
                    "time",
                    window.trim_controller,
                    "trim_start",
                    BindingFlags.BIDIRECTIONAL
                );

                end_entry.bind_property (
                    "time",
                    window.trim_controller,
                    "trim_end",
                    BindingFlags.BIDIRECTIONAL
                );

                timeline.bind_property (
                    "trim_start",
                    window.trim_controller,
                    "trim_start",
                    BindingFlags.BIDIRECTIONAL
                );

                timeline.bind_property (
                    "trim_end",
                    window.trim_controller,
                    "trim_end",
                    BindingFlags.BIDIRECTIONAL
                );

            });

            /* making sure the values are within bounds */
            start_entry.activate.connect (() => {
                if (start_entry.time < 0) {
                    start_entry.time = 0;
                }
            });

            end_entry.activate.connect (() => {
                if (end_entry.time > window.trim_controller.duration) {
                    end_entry.time = (int) window.trim_controller.duration;
                }
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
