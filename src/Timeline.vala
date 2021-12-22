namespace Trimmer {
    public class Timeline : Gtk.Box {
        private Gtk.CssProvider css_provider;

        public Timeline () {
            Object (
                orientation : Gtk.Orientation.HORIZONTAL,
                spacing : 0
                );
        }

        construct {
            var style_context = get_style_context ();
            style_context.add_class ("timeline");
            height_request = 24;

            css_provider = new Gtk.CssProvider ();
            try {
                css_provider.load_from_path ("/home/adithyankv/Code/personal_projects/trimmer/src/timeline.css");
            } catch (Error e) {
                critical (e.message);
            }
            style_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
