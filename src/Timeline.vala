namespace Trimmer {
    public class Timeline : Granite.SeekBar {
        private Gtk.CssProvider css_provider;

        public Timeline (double playback_duration) {
            Object (
                playback_duration : playback_duration
            );
        }

        construct {
            /* The seek-bar scale is slightly modified with a custom style 
               sheet so as to make interacting with the trimming UI easier */
            var style_context = get_style_context ();
            style_context.add_class ("timeline");

            css_provider = new Gtk.CssProvider ();
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
        }
    }
}
