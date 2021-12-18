namespace Trimmer {
    public class HeaderBar : Gtk.HeaderBar {
        public Trimmer.Window window {get; set;}

        public HeaderBar (Trimmer.Window window) {
            Object (
                window : window
            );
        }
        construct {
            title = "Trimmer";
            show_close_button = true;

            var open_button = new Gtk.Button.from_icon_name ("document-open", 
                                                             Gtk.IconSize.LARGE_TOOLBAR) {
                tooltip_text = "Open video"
            };
            open_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_OPEN).activate (null);
            });

            pack_start (open_button);
        }
    }
}
