namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0
            );
        }

        construct {
            video_player = new VideoPlayer (this);

            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
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

            pack_start (video_player, true, true, 0);
            pack_start (timeline_box, false, false, 0);
            pack_start (button_box, false, false, 0);
        }
    }
}
