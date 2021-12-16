namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Stack content_stack;
        private Trimmer.WelcomeView welcome_view;
        public Trimmer.TrimView trim_view;

        public Window (Gtk.Application app) {
            Object (
                application: app
                );
        }

        construct {
            content_stack = new Gtk.Stack ();
            welcome_view = new Trimmer.WelcomeView (this);
            trim_view = new Trimmer.TrimView ();

            content_stack.add (welcome_view);
            content_stack.add (trim_view);
            add (content_stack);
        }
    }
}
