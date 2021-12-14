namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Stack content_stack;

        public Window (Gtk.Application app) {
            Object (
                application: app
                );
        }

        construct {
            content_stack = new Gtk.Stack ();
            var welcome_view = new Granite.Widgets.Welcome (
                "No videos open",
                "Open a video to trim it"
                );
            welcome_view.append ("folder-videos", "Open video", "Open a video file");

            welcome_view.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        print ("something");
                }
            });

            content_stack.add (welcome_view);
            add (content_stack);
        }
    }
}
