namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Stack content_stack;
        private Trimmer.WelcomeView welcome_view;

        public Window (Gtk.Application app) {
            Object (
                application: app
                );
        }

        construct {
            content_stack = new Gtk.Stack ();
            welcome_view = new Trimmer.WelcomeView ();

            content_stack.add (welcome_view);
            add (content_stack);
        }
    }
}
