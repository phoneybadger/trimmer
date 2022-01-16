namespace Trimmer {
    public class Application : Gtk.Application {
        public Application () {
            Object (
                application_id : "com.github.adithyankv.trimmer",
                flags : ApplicationFlags.FLAGS_NONE
                );
        }

        protected override void activate () {
            set_prefered_color_scheme ();

            var window = new Trimmer.Window (this);
            window.show_all ();
        }
    }

    private void set_prefered_color_scheme () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme
            == Granite.Settings.ColorScheme.DARK;
        // live reloads colorscheme
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme
                == Granite.Settings.ColorScheme.DARK;
        });
    }
}
