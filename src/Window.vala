namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Stack content_stack;
        private Trimmer.WelcomeView welcome_view;
        public Trimmer.TrimView trim_view;
        public Gtk.Application app {get; set construct;}

        public SimpleActionGroup actions;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_OPEN = "action_open";

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public const ActionEntry[] ACTION_ENTRIES = {
            {ACTION_OPEN, action_open},
        };

        public Window (Gtk.Application app) {
            Object (
                application: app,
                app : app
                );
        }

        static construct {
            action_accelerators.set(ACTION_OPEN, "<Ctrl>o");
        }

        construct {
            set_up_actions ();

            content_stack = new Gtk.Stack ();
            welcome_view = new Trimmer.WelcomeView (this);
            trim_view = new Trimmer.TrimView ();

            content_stack.add (welcome_view);
            content_stack.add (trim_view);
            add (content_stack);
        }

        private void set_up_actions () {
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
        }

        private void action_open () {
            var file_chooser = new Gtk.FileChooserNative (
                "Open video",
                this,
                Gtk.FileChooserAction.OPEN,
                "Open",
                "Cancel");

            // show only video files
            var video_files_filter = new Gtk.FileFilter ();
            video_files_filter.set_filter_name ("Video files");
            video_files_filter.add_mime_type ("video/*");
            file_chooser.add_filter (video_files_filter);

            var response = file_chooser.run ();
            file_chooser.destroy ();

            if (response == Gtk.ResponseType.ACCEPT) {
                var uri = file_chooser.get_uri ();
                content_stack.visible_child = trim_view;
                trim_view.load_and_play_video (uri);
            }
        }
    }
}
