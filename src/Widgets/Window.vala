/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class Window : Gtk.ApplicationWindow {
        public Gtk.Stack content_stack;
        private Trimmer.WelcomeView welcome_view;
        public Trimmer.TrimView trim_view;
        public Gtk.Application app {get; set construct;}

        private GLib.Settings settings;

        public SimpleActionGroup actions;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_OPEN = "action_open";
        public const string ACTION_PLAY_PAUSE = "action_play_pause";
        public const string ACTION_QUIT = "action_quit";
        public const string ACTION_TRIM = "action_trim";

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public const ActionEntry[] ACTION_ENTRIES = {
            {ACTION_OPEN, action_open},
            {ACTION_QUIT, action_quit},
            {ACTION_PLAY_PAUSE, action_play_pause, null, "false"}, //false if video is playing
            {ACTION_TRIM, action_trim}
        };

        public Window (Gtk.Application app) {
            Object (
                application: app,
                app : app
                );
        }

        static construct {
            action_accelerators.set (ACTION_OPEN, "<Ctrl>o");
            action_accelerators.set (ACTION_QUIT, "<Ctrl>q");
        }

        construct {
            default_width = 640;
            default_height = 480;

            set_up_actions ();
            init_layout ();
            load_config_from_schema ();
            setup_drag_and_drop ();

            delete_event.connect (() => {
                save_config_to_schema ();
            });

            destroy.connect (() => {
                actions.lookup_action (ACTION_QUIT).activate (null);
            });

        }

        private void setup_drag_and_drop () {
            Gtk.TargetEntry target = {"text/uri-list", 0, 0};
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, {target}, Gdk.DragAction.COPY);
        }

        private void init_layout () {
            var header_bar = new Trimmer.HeaderBar (this);
            set_titlebar (header_bar);

            content_stack = new Gtk.Stack ();
            welcome_view = new Trimmer.WelcomeView (this);
            trim_view = new Trimmer.TrimView (this);

            content_stack.add (welcome_view);
            content_stack.add (trim_view);
            add (content_stack);
        }

        private void load_config_from_schema () {
            settings = new Settings ("com.github.phoneybadger.trimmer");
            int pos_x, pos_y;
            settings.get ("position", "(ii)", out pos_x, out pos_y);
            move (pos_x, pos_y);

            int win_width, win_height;
            settings.get ("dimensions", "(ii)", out win_width, out win_height);
            resize (win_width, win_height);

            bool maximized;
            settings.get ("maximized", "b", out maximized);
            if (maximized) {
                maximize ();
            }
        }

        private void save_config_to_schema () {
            int width, height, x, y;
            get_size (out width, out height);
            get_position (out x, out y);

            settings.set ("position", "(ii)", x, y);
            settings.set ("dimensions", "(ii)", width, height);
            settings.set ("maximized", "b", is_maximized);
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
                _("Open video"),
                this,
                Gtk.FileChooserAction.OPEN,
                _("Open"),
                _("Cancel")
            );

            // show only video files
            var video_files_filter = new Gtk.FileFilter ();
            video_files_filter.set_filter_name (_("Video files"));
            video_files_filter.add_mime_type ("video/*");
            file_chooser.add_filter (video_files_filter);

            var response = file_chooser.run ();
            file_chooser.destroy ();

            if (response == Gtk.ResponseType.ACCEPT) {
                var uri = file_chooser.get_uri ();
                content_stack.visible_child = trim_view;
                trim_view.video_player.play_video (uri);
            }
        }

        private void action_play_pause () {
            trim_view.video_player.toggle_play_pause ();
        }

        private void action_quit () {
            trim_view.video_player.stop_and_destroy ();
            destroy ();
        }

        private void action_trim () {
            var trim_controller = trim_view.trim_controller;
            var file_chooser = new Gtk.FileChooserNative (
                _("Save video"),
                null,
                Gtk.FileChooserAction.SAVE,
                _("Save"),
                _("Cancel")
            );
            var video_files_filter = new Gtk.FileFilter ();
            video_files_filter.set_filter_name (_("Video files"));
            video_files_filter.add_mime_type ("video/*");
            file_chooser.add_filter (video_files_filter);
            file_chooser.do_overwrite_confirmation = true;

            /* 
               Suggest an output name of input_name-trimmed.extension
               for example
               video.mp4 becomes video-trimmed.mp4
            */
            var filename = trim_controller.filename;
            var extension = trim_controller.file_extension;
            /// TRANSLATORS: This is the default suggested file name when
            /// the user tries to save a trimmed video file. The first %s
            /// represents the original file name before trim and the 
            /// second one is the file extension
            var suggested_filename = _("%s-trimmed.%s").printf (filename, extension);
            file_chooser.set_current_name (suggested_filename);

            var response = file_chooser.run ();
            file_chooser.destroy ();

            if (response == Gtk.ResponseType.ACCEPT) {
                var uri = file_chooser.get_uri ();
                if (uri == null) {
                    return;
                }
                /* we are suggesting the user a file extension in the 
                   name field of the file chooser. But if the user goes
                   out of their way to remove it, we'll re-add the file
                   extension. Not foolproof, the user could've replaced
                   the extension with an invalid one. But in that case
                   I guess it is acceptable to just let the trim fail. */
                try {
                    Utils.get_file_extension (uri);
                } catch (Utils.NoExtensionError e) {
                    debug ("User inputed no extension. Adding extension");
                    uri = "%s.%s".printf (uri, extension);
                }
                trim_controller.save_file_uri = uri;
                trim_controller.trim.begin ();
            }
        }
    }
}
