namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Window (Gtk.Application app) {
            Object (
                application: app
                );
        }
    }
}
