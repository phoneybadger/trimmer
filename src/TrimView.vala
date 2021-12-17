namespace Trimmer {
    public class TrimView : Gtk.Box {
        public Trimmer.VideoPlayer video_player;

        public TrimView () {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0
            );
        }

        construct {
            video_player = new VideoPlayer ();

            var layout_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 20) {
                margin = 10
            };

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20) {
                halign = Gtk.Align.CENTER
            };

            var frame_range = new Gtk.Adjustment (0, 0, 100, 10, 10, 10);
            var start_frame_label = new Gtk.Label ("Start") {
                halign = Gtk.Align.END
            };
            var end_frame_label = new Gtk.Label ("End") {
                halign = Gtk.Align.END
            };
            var start_frame = new Gtk.SpinButton (frame_range, 10, 3);
            var end_frame = new Gtk.SpinButton (frame_range, 10, 3);

            start_end_box.pack_start (start_frame_label);
            start_end_box.pack_start (start_frame);
            start_end_box.pack_start (end_frame_label);
            start_end_box.pack_start (end_frame);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };
            var trim_button = new Gtk.Button.with_label ("Trim");
            trim_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_box.pack_end (trim_button);

            layout_box.pack_start (start_end_box, false, false, 0);
            layout_box.pack_start (button_box, false, false, 0);

            pack_start (video_player);
            pack_start (layout_box, false, false, 0);
        }
    }
}
