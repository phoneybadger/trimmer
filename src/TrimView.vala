namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        private Gtk.Button play_button;
        public Trimmer.TimeStampEntry start_entry;
        public Trimmer.TimeStampEntry end_entry;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            video_player = new VideoPlayer (this);

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");
            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            // Initialize with 0 as no video will be loaded initially
            seeker = new Granite.SeekBar (0.0);
            timeline_box.pack_start (play_button, false, false, 0);
            timeline_box.pack_start (seeker, false, true, 0);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };
            var trim_button = new Gtk.Button.with_label ("Trim");
            trim_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_box.pack_end (trim_button);

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                halign = Gtk.Align.CENTER
            };

            var start_label = new Gtk.Label ("Start");
            var end_label = new Gtk.Label ("End");

            start_entry = new Trimmer.TimeStampEntry ();
            end_entry = new Trimmer.TimeStampEntry ();

            // check if trim boundaries are within video clip duration and also
            // ensure start comes before end.
            start_entry.activate.connect (() => {
                var min = 0;
                var max = end_entry.timestamp_in_seconds ();
                start_entry.check_bounds (min, max);
            });
            end_entry.activate.connect (() => {
                var min = start_entry.timestamp_in_seconds ();
                var max = video_player.playback.duration;
                end_entry.check_bounds (min, max);
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
