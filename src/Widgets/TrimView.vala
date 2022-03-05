namespace Trimmer {
    public class TrimView : Gtk.Box {
        public unowned Trimmer.Window window {get; set;}
        public Trimmer.Timeline timeline {get; set;}
        private Trimmer.MessageArea message_area;
        public Trimmer.VideoPlayer video_player;
        public Granite.SeekBar seeker;
        public Trimmer.Controllers.TrimController trim_controller;

        private Gtk.Button play_button;
        private Trimmer.TimeStampEntry start_entry;
        private Trimmer.TimeStampEntry end_entry;
        private Gtk.Button trim_button;
        private Trimmer.TrimmingDialog trimming_dialog;

        public TrimView (Trimmer.Window window) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0,
                window: window
            );
        }

        construct {
            create_layout ();

            play_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_PLAY_PAUSE).activate (null);
            });

            video_player.video_loaded.connect ((duration, uri) => {
                timeline.playback_duration = duration;
                trim_controller.duration = duration;
                trim_controller.video_uri = uri;
            });

            timeline.bind_property (
                "start-time",
                trim_controller,
                "trim-start-time",
                BindingFlags.BIDIRECTIONAL
            );

            timeline.bind_property (
                "end-time",
                trim_controller,
                "trim-end-time",
                BindingFlags.BIDIRECTIONAL
            );

            start_entry.bind_property (
                "time",
                trim_controller,
                "trim-start-time",
                BindingFlags.BIDIRECTIONAL
            );

            end_entry.bind_property (
                "time",
                trim_controller,
                "trim-end-time",
                BindingFlags.BIDIRECTIONAL
            );

            start_entry.changed.connect (check_trim_validity);
            end_entry.changed.connect (check_trim_validity);

            trim_controller.trim_failed.connect ((message) => {
                message_area.add_message (Gtk.MessageType.ERROR, message);
            });

            trim_controller.trim_success.connect ((message) => {
                // TODO: Implement a handler for this to give some feedback to 
                // the user. Perhaps a toast.
            });

            trim_button.clicked.connect (() => {
                window.actions.lookup_action (Window.ACTION_TRIM).activate (null);
            });

            end_entry.notify ["time"].connect (() => {
                if (end_entry.time > trim_controller.duration) {
                    end_entry.time = (int) trim_controller.duration;
                    end_entry.text = Granite.DateTime.seconds_to_time (end_entry.time);
                }
            });

            trim_controller.notify ["trim-state"].connect (() => {
                /* as longer videos can take some time to trim, show the user
                an in-progress dialog */
                trimming_dialog.filename = Utils.get_filename (trim_controller.video_uri);
                trimming_dialog.transient_for = window;
                if (trim_controller.trim_state == Controllers.TrimController.TrimState.TRIMMING) {
                    trimming_dialog.show ();
                } else {
                    trimming_dialog.hide ();
                }
            });
        }

        private void create_layout () {
            message_area = new MessageArea ();
            video_player = new VideoPlayer (this);
            trim_controller = new Controllers.TrimController ();
            trimming_dialog = new TrimmingDialog ();


            var timeline_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                valign = Gtk.Align.CENTER
            };
            play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic");

            timeline = new Timeline (video_player);
            timeline_box.pack_start (play_button, false, false, 0);
            timeline_box.pack_start (timeline, false, true, 0);

            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
                layout_style = Gtk.ButtonBoxStyle.END
            };

            trim_button = new Gtk.Button.with_label (_("Trim")) {
                margin = 5
            };
            trim_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_box.pack_end (trim_button);

            var start_end_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 10,
                halign = Gtk.Align.CENTER
            };

            /// TRANSLATORS: these are the labels for entries representing
            /// timestamps from where the trim should start and end
            var start_label = new Gtk.Label (_("Start"));
            var end_label = new Gtk.Label (_("End"));

            start_entry = new Trimmer.TimeStampEntry ();
            end_entry = new Trimmer.TimeStampEntry ();

            start_end_box.pack_start (start_label, false, false, 10);
            start_end_box.pack_start (start_entry, false, false, 10);
            start_end_box.pack_start (end_label, false, false, 10);
            start_end_box.pack_start (end_entry, false, false, 10);

            pack_start (message_area, false, false, 0);
            pack_start (video_player, true, true, 0);
            pack_start (timeline_box, false, false, 0);
            pack_start (start_end_box, false, false, 0);
            pack_start (button_box, false, false, 0);
        }

        private void check_trim_validity () {
            if (start_entry.is_valid_timestamp () &&
                end_entry.is_valid_timestamp ()) {

                /* both entries being marked as invalid to distinguish this from
                the case where a timestamp is invalid, in which case only the
                entry with invalid timestamp will be marked invalid */
                var start_time = Utils.convert_timestamp_to_seconds (start_entry.text);
                var end_time = Utils.convert_timestamp_to_seconds (end_entry.text);
                bool is_start_before_end = (start_time < end_time);
                start_entry.is_valid = is_start_before_end;
                end_entry.is_valid = is_start_before_end;
                trim_button.sensitive = is_start_before_end;

            } else {
                trim_button.sensitive = false;
            }
        }

        public void update_play_button_icon () {
            if (video_player.playback.playing) {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-pause-symbolic";
            } else {
                ((Gtk.Image) play_button.image).icon_name = "media-playback-start-symbolic";
            }
        }
    }
}
