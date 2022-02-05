namespace Trimmer {
    public class TimeStampEntry : Gtk.Entry {
        private Regex timestamp_regex;

        private bool _is_valid;
        public bool is_valid {
            get {
                return _is_valid;
            } set {
                _is_valid = value;
            }
        }

        private int _time;
        public int time {
            get {
                return _time;
            } set {
                _time = value;
            }
        }

        construct {
            placeholder_text = "00:00:00";

            setup_timestamp_regex ();

            notify ["is-valid"].connect (() => {
                update_style ();
            });

            notify ["time"].connect (() => {
                text = Granite.DateTime.seconds_to_time (time);
            });

            activate.connect (() => {
                if (is_valid) {
                    time = Utils.convert_timestamp_to_seconds (text);
                }
            });

            focus_out_event.connect (() => {
                activate ();
            });

            changed.connect (validate);
        }

        public void validate () {
            if (timestamp_regex.match (text)) {
                is_valid = true;
            } else {
                is_valid = false;
            }
        }

        public void update_style () {
            /* change UI style to invalid or valid styles depending on state */
            var style_context = get_style_context ();
            if (is_valid) {
                secondary_icon_name = "process-completed-symbolic";
                style_context.remove_class (Gtk.STYLE_CLASS_ERROR);
            } else {
                secondary_icon_name = "process-error-symbolic";
                style_context.add_class (Gtk.STYLE_CLASS_ERROR);
            }
        }

        private void setup_timestamp_regex () {
            try {
                // Regex for hours:minutes:seconds
                /*

                ^                                       start of string
                    (
                        ([0-9]+:)?                      optionally match hours:
                        ([0-5]?[0-9]:)                  match mm: or m: with mm < 60, m <10
                    )?                                  optionally match hours:mm
                    ([0-5]?[0-9])                       match ss or s. ss < 60, s < 10
                $                                       end of string

                */
                timestamp_regex = new Regex ("^(([0-9]+:)?([0-5]?[0-9]:))?([0-5]?[0-9])$");
            } catch (RegexError e) {
                critical (e.message);
            }
        }
    }
}
